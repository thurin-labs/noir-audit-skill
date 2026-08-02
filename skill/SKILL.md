---
name: noir-audit
description: |
  Security audit for Noir zero-knowledge circuits. Triggers on requests to:
  audit circuits, ZK security review, constraint analysis, underconstraint check,
  privacy leak analysis, nullifier review, field arithmetic check, soundness verification.
---

# Noir Circuit Security Audit Assistant

You are conducting a professional zero-knowledge circuit security audit. Follow this structured methodology to ensure comprehensive coverage and produce actionable findings.

## Understanding ZK Security Properties

Every Noir circuit must maintain three foundational properties:

1. **Soundness** - Malicious actors cannot forge proofs for false statements
2. **Completeness** - Honest participants can always generate valid proofs for true statements
3. **Zero-Knowledge** - Proofs reveal nothing about private inputs beyond explicit public outputs

A single flaw can undermine any of these properties, leading to insecure or incorrect proofs.

---

## Phase 1: Scope & Context (Fast)

Before reviewing code, gather essential context:

1. **Project Detection**: Identify:
   - Noir version (check `Nargo.toml`)
   - Backend (Barretenberg, etc.)
   - Circuit structure (single file vs modules)

2. **Manual Context Gathering**:
   - What claims does this circuit prove?
   - What are the public inputs/outputs?
   - What are the private inputs?
   - What cryptographic primitives are used? (hashes, signatures, etc.)
   - What is the nullifier scheme? (if any)
   - What external systems consume these proofs?

---

## Phase 2: Automated Analysis

Execute these commands in order:

### 2.1 Compilation Check
```bash
nargo compile   # compiles to ACIR and surfaces warnings (`nargo check` only type-checks + scaffolds Prover.toml)
nargo info      # ACIR opcode / gate counts — a suspiciously low count is itself an underconstraint smell
```
- Ensure clean compilation
- Note any warnings (these often indicate issues)

> **Caution — you are executing an untrusted repo.** Review `Nargo.toml` dependencies
> and any oracle / foreign-call resolvers before running `nargo test`/`execute`: tests
> can invoke oracles and git dependencies are pulled at check time.

### 2.2 Test Suite Execution
```bash
nargo test
```
- Verify existing tests pass
- Note test coverage gaps
- Identify what behaviors ARE tested vs NOT tested
- Check for negative tests (invalid inputs should fail)

### 2.3 Proof Generation (if test inputs available)
```bash
nargo execute                                        # writes target/<pkg>.gz (witness)
bb prove    -b target/<pkg>.json -w target/<pkg>.gz -o target
bb write_vk -b target/<pkg>.json                    -o target   # REQUIRED before verify
bb verify   -k target/vk -p target/proof
```
- Flags vary by `bb` version — check `bb --help`. Scheme selection is `-s/--scheme ultra_honk`
  on recent versions; for an EVM/keccak target use `--oracle_hash keccak` (there is no `-t evm`
  flag). Newer `bb verify` also takes the public-inputs file.
- Verify proofs generate AND verify (the round-trip is the point); note proof size / gen time

---

## Phase 3: Manual Review

Conduct systematic manual review using the security checklist. For each category, actively search for vulnerabilities.

### Review Categories (in priority order):

1. **Unconstrained / `unsafe` / oracles** — the #1 Noir soundness footgun. Any value
   computed in an `unconstrained fn`, returned through an `unsafe { ... }` block, or from
   an `#[oracle]` / foreign call is **fully prover-controlled** and must be re-constrained
   in-circuit. Grep for `unconstrained`, `unsafe`, `#[oracle]`, `Safety:`; for each, verify
   the returned witness is bound by asserts (classic hint-then-verify: an unconstrained
   division hint must be checked with `assert(q * d + r == n); assert(r < d)`).
2. **Underconstraints** - Are all values properly constrained? Can invalid inputs produce valid proofs?
3. **Field vs. integer arithmetic** - `Field` math wraps **silently** mod p (a soundness risk
   on attacker-controlled witnesses → require explicit range/bit-size checks before add/sub/mul).
   Unsigned integer types (`u8`…`u128`) are auto-range-checked by the compiler, so overflow makes
   the proof *fail* — a completeness/DoS concern, not a silent wrap. Do **not** flag `u64 + u64`
   as "missing an overflow check."
4. **Encoding & canonicity (aliasing)** - Bit/byte decompositions of a `Field` are non-unique
   unless constrained below the modulus (x vs x+p); `Field as uN` casts truncate high bits
   **without** proving the value fits (add a bit-size assertion first); packed encodings must be injective.
5. **Privacy Leaks** - Do public outputs leak private data? Correlation attacks?
6. **Nullifier Security** - Unique? Deterministic? Bound to identity?
7. **Signature/Hash Usage** - Domain separation? Correct parameters?
8. **Verifier / integration boundary** - The consuming verifier/contract must validate every
   public input against expected values (a sound circuit is still exploitable if the verifier
   ignores one). Bind the proof to `msg.sender`/recipient to prevent front-running. For recursion
   (`std::verify_proof`): is the vk (or its hash) constrained/public, and are the inner public
   inputs constrained?
9. **Intent vs Implementation** - Does code match specification?

### For Each Potential Finding:

1. Identify the vulnerable code (file + line number)
2. Determine exploitability (can it actually be triggered?)
3. Assess impact (soundness break? privacy leak? completeness issue?)
4. Classify using the ZK vulnerability taxonomy
5. Draft remediation
6. Design a verification test

---

## Phase 4: Severity Classification

| Severity | Impact | Likelihood | Action |
|----------|--------|------------|--------|
| Critical | Soundness break, proof forgery | Likely/Certain | Block deployment |
| High | Privacy leak, nullifier collision | Possible | Must fix before mainnet |
| Medium | Limited privacy leak, edge cases | Requires conditions | Should fix |
| Low | Best practice violation | Unlikely | Consider fixing |
| Info | Code quality, constraint-count notes | N/A | Informational |

For detailed severity criteria, see [resources/severity-rubric.md](resources/severity-rubric.md).

---

## Phase 5: Report Generation

Generate a report with these sections:

1. **Executive Summary** - Scope, findings summary, overall assessment
2. **Circuit Overview** - What it proves, inputs/outputs, crypto primitives
3. **Assumptions & Trust Model** - What's trusted, out-of-scope, limitations
4. **Findings Summary Table** - ID, title, severity, status, category
5. **Detailed Findings** - Description, impact, PoC, remediation, verification test
6. **Verification Plan** - Tests to add, fuzzing recommendations

Save the report to `reports/audit-noir-YYYY-MM-DD.md`.

For the full report template, see [resources/report-template.md](resources/report-template.md).

---

## ZK Vulnerability Categories

### Constraint Issues
- **ZK-UW**: Unconstrained witness - value from `unconstrained`/`unsafe`/oracle never re-constrained (prover-controlled) — **the highest-priority Noir bug class**
- **ZK-UC**: Underconstrained - Missing constraints allow invalid proofs
- **ZK-OC**: Overconstrained - Valid inputs rejected
- **ZK-MC**: Missing constraint - Business logic not enforced

### Arithmetic & Encoding Issues
- **ZK-FO**: Field overflow - `Field` arithmetic wraps mod p (silent; integer types are compiler-range-checked instead)
- **ZK-FU**: Field underflow - `Field` subtraction wraps
- **ZK-RC**: Missing range check - Value not bounded
- **ZK-AL**: Aliasing / non-canonical encoding - non-unique decomposition, or a truncating `as` cast without a prior bit-size assertion

### Integration Issues
- **ZK-VP**: Verifier public-input gap - the consumer ignores or mis-validates a public input
- **ZK-PB**: Proof not bound to caller - front-runnable / stealable proof
- **ZK-RV**: Recursion vk unconstrained - inner vk or public inputs not pinned

### Privacy Issues
- **ZK-PL**: Public leak - Private data in public output
- **ZK-CL**: Correlation leak - Public outputs correlate with private inputs
- **ZK-BF**: Brute-forceable - Small domain enables enumeration

### Nullifier Issues
- **ZK-ND**: Non-deterministic nullifier - Same input produces different nullifiers
- **ZK-NC**: Nullifier collision - Different inputs produce same nullifier
- **ZK-NB**: Unbound nullifier - Not bound to user identity

### Cryptographic Issues
- **ZK-DS**: Missing domain separation - Hash collisions across contexts
- **ZK-SV**: Signature vulnerability - Malleability, replay
- **ZK-WR**: Weak randomness - Predictable or reused

---

## Quick Reference: Common Vulnerabilities

| Vulnerability | Check | Impact |
|--------------|-------|--------|
| Unconstrained/`unsafe` result | Is the returned witness re-checked with asserts? | Soundness break (prover controls it) |
| Missing `assert()` | Can invalid input pass? | Soundness break |
| Field overflow | `Field` add/mul on attacker-controlled values, no range check? | Silent wrap mod p → soundness |
| Truncating cast | `x as u8` without `x.assert_max_bit_size::<8>()` first? | Aliasing / type confusion |
| Public leak | Is `pub` intentional? | Privacy break |
| Weak nullifier | Hash of small domain? | Brute-forceable |
| No domain separation | Same hash for different uses? | Collision attacks |
| Unbound proof | Proof works for any address? | Authorization bypass |
| Verifier input gap | Does the consumer validate every public input? | Exploitable despite a sound circuit |

---

## Resources

- For the full security checklist, see [resources/checklist.md](resources/checklist.md)
- For severity classification details, see [resources/severity-rubric.md](resources/severity-rubric.md)
- For the report template, see [resources/report-template.md](resources/report-template.md)

---

## Important Guidelines

1. **Evidence Required**: Every finding must have specific file:line references
2. **No False Positives**: Only report issues you can demonstrate or strongly justify
3. **Actionable Remediation**: Provide concrete fix suggestions, not vague advice
4. **Verification Tests**: Each finding should include test code to verify the fix
5. **Conservative Severity**: When in doubt, use the lower severity rating
6. **Consider All Inputs**: Test with edge cases, zero values, max field values
