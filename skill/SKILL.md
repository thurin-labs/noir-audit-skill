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
nargo check
```
- Ensure clean compilation
- Note any warnings (these often indicate issues)

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
nargo execute
bb prove -b target/<circuit>.json -w target/<circuit>.gz -o target/proof -t evm
bb verify -k target/vk/vk -p target/proof/proof
```
- Verify proofs generate and verify correctly
- Note proof size and generation time

---

## Phase 3: Manual Review

Conduct systematic manual review using the security checklist. For each category, actively search for vulnerabilities.

### Review Categories (in priority order):

1. **Underconstraints** - Are all values properly constrained? Can invalid inputs produce valid proofs?
2. **Field Arithmetic** - Overflow/underflow in finite field? Missing range checks?
3. **Privacy Leaks** - Do public outputs leak private data? Correlation attacks?
4. **Nullifier Security** - Unique? Deterministic? Bound to identity?
5. **Signature/Hash Usage** - Domain separation? Correct parameters?
6. **Intent vs Implementation** - Does code match specification?

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
| Info | Code quality, gas optimization | N/A | Informational |

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
- **ZK-UC**: Underconstrained - Missing constraints allow invalid proofs
- **ZK-OC**: Overconstrained - Valid inputs rejected
- **ZK-MC**: Missing constraint - Business logic not enforced

### Arithmetic Issues
- **ZK-FO**: Field overflow - Arithmetic wraps around field modulus
- **ZK-FU**: Field underflow - Subtraction wraps around
- **ZK-RC**: Missing range check - Value not bounded

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
| Missing `assert()` | Can invalid input pass? | Soundness break |
| Field overflow | `a + b` where both are large | Incorrect arithmetic |
| Missing range check | Is `x < 256` enforced? | Type confusion |
| Public leak | Is `pub` intentional? | Privacy break |
| Weak nullifier | Hash of small domain? | Brute-forceable |
| No domain separation | Same hash for different uses? | Collision attacks |
| Unbound proof | Proof works for any address? | Authorization bypass |

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
