# Noir Circuit Security Checklist

Use this checklist during manual review. For each item, actively search for vulnerabilities.

## 0. Unconstrained / Unsafe / Oracles (highest priority)

Values produced outside the constraint system are **prover-controlled** until re-checked
in-circuit. This is the #1 Noir soundness bug class.

- [ ] Every `unconstrained fn` result consumed through an `unsafe { ... }` block is re-constrained
- [ ] Each `unsafe` block has a `Safety:` comment and matching asserts that pin the returned witness
- [ ] Oracle / foreign-call (`#[oracle]`) outputs are validated, never trusted directly
- [ ] Hint-then-verify is complete (e.g. division: `assert(q * d + r == n); assert(r < d)`)

**Test**: `grep -rn "unconstrained\|unsafe\|#\[oracle\]"` and, for each, confirm a malicious
prover cannot freely choose the result.

## 1. Constraint Completeness

### 1.1 Input Validation
- [ ] All public inputs are validated/constrained
- [ ] All private inputs have appropriate range checks
- [ ] Array indices are bounds-checked
- [ ] Optional/conditional values are properly handled

### 1.2 Business Logic Constraints
- [ ] Every business rule has a corresponding `assert()` or constraint
- [ ] Conditional logic (`if/else`) properly constrains all branches
- [ ] Loop bounds are compile-time constants; watch for generics instantiated too small and `break` inside unconstrained code
- [ ] Return values are constrained, not just computed
- [ ] Any `Field` used as a 0/1 selector is constrained boolean (`assert(b * (b - 1) == 0)`) or uses the `bool` type

### 1.3 Underconstraint Detection
- [ ] Can any private input be changed without invalidating the proof?
- [ ] Are there "free" variables that aren't constrained?
- [ ] Do all code paths lead to proper constraints?
- [ ] Are intermediate values used in final constraints?

**Test**: For each private input, ask "What happens if I change this value?"

## 2. Arithmetic Safety

Know the difference: **`Field` arithmetic wraps silently mod p** (the soundness risk).
**Unsigned integer types (`u8`…`u128`) are compiler-range-checked** — overflow makes the proof
*fail* (a completeness / DoS concern), it does not silently wrap. Don't flag ordinary `uN`
arithmetic as "missing an overflow check."

### 2.1 Field arithmetic (silent wrap)
- [ ] `Field` add/sub/mul on attacker-controlled witnesses is preceded by explicit range or bit-size checks
- [ ] No reliance on a `Field` "not overflowing" — the prover chooses the witness
- [ ] Division / inverse guards against zero

### 2.2 Range checks (use the real API)
- [ ] Bound a `Field` before trusting its size: `x.assert_max_bit_size::<8>()`, or cast to a
      sized integer type. (`Field` has **no** `<` / `.lt()` — comparisons exist only on integer types.)
- [ ] Timestamps, amounts, and indices are bounded to their expected ranges
- [ ] `Field as uN` casts are preceded by a bit-size assertion (a bare cast truncates, it doesn't prove fit)

### 2.3 Encoding & canonicity
- [ ] Bit/byte decompositions are constrained canonical (below the modulus — no x vs x+p aliasing)
- [ ] Packed encodings are injective (no two witnesses map to the same packed value)

**Test**: Try values near the field modulus, zero, and max expected values.

## 3. Privacy Analysis

### 3.1 Public Input/Output Review
- [ ] Every `pub` variable is intentionally public
- [ ] No private data accidentally marked as public
- [ ] Public outputs don't reveal private input patterns

### 3.2 Correlation Analysis
- [ ] Public outputs don't correlate with sensitive private inputs
- [ ] Aggregated values don't leak individual components
- [ ] Timing/ordering doesn't reveal private information

### 3.3 Brute-Force Resistance
- [ ] Hashed values have sufficient entropy (not small domains)
- [ ] Age values, dates, small enums are protected
- [ ] Nullifiers aren't derived from guessable inputs alone

**Test**: For each public output, ask "What can an attacker learn by observing this?"

## 4. Nullifier Security

### 4.1 Uniqueness
- [ ] Same identity always produces same nullifier (deterministic)
- [ ] Different identities produce different nullifiers (collision-resistant)
- [ ] Nullifier includes all identity-binding components

### 4.2 Binding
- [ ] Nullifier is bound to user identity (document number, secret, etc.)
- [ ] Nullifier is bound to action/event (event ID, context)
- [ ] Nullifier cannot be reused across different contexts

### 4.3 Privacy
- [ ] Nullifier doesn't reveal identity (uses hash/commitment)
- [ ] Multiple nullifiers from same user are unlinkable (if required)
- [ ] Nullifier scheme is documented and matches implementation

**Common pattern** (illustrative — the real call is
`std::hash::poseidon2::Poseidon2::hash(inputs, N)`, and Poseidon/Poseidon2 have moved to an
external library in recent Noir releases; confirm against the project's version):
```noir
let nullifier = std::hash::poseidon2::Poseidon2::hash([user_secret, event_id, context], 3);
```

## 5. Cryptographic Primitive Usage

### 5.1 Hash Functions
- [ ] Domain separation used (different prefixes for different uses)
- [ ] Correct hash function for use case (Poseidon2 for ZK, SHA for compatibility)
- [ ] Hash inputs are properly serialized (no ambiguity)
- [ ] Preimage resistance requirements met

### 5.2 Signatures
- [ ] Signature verification uses correct curve/parameters
- [ ] Public key is properly validated
- [ ] Message includes all relevant context (no replay)
- [ ] Signature malleability considered

### 5.3 Merkle Trees
- [ ] Leaf encoding prevents second-preimage attacks
- [ ] Tree depth is validated
- [ ] Index/path validation is correct

**Test**: Can the same hash/signature be valid in multiple contexts?

## 6. Intent vs Implementation

### 6.1 Specification Alignment
- [ ] Circuit proves exactly what specification says
- [ ] No additional assumptions beyond specification
- [ ] Edge cases in spec are handled in code

### 6.2 Authorization Logic
- [ ] Proofs are bound to specific users/addresses
- [ ] Time/expiry constraints are enforced
- [ ] Scope limitations are enforced (what can be proven)

### 6.3 External Assumptions
- [ ] Trust assumptions are documented
- [ ] External data sources (oracles) are validated
- [ ] Upgrade/migration paths don't break security

**Test**: Read the spec, then check if code matches exactly.

## 7. Code Quality

### 7.1 Clarity
- [ ] Variable names clearly indicate purpose
- [ ] Complex logic is commented
- [ ] Public/private inputs are documented

### 7.2 Testing
- [ ] Positive tests (valid inputs produce valid proofs)
- [ ] Negative tests (invalid inputs fail)
- [ ] Edge case tests (zero, max, boundary values)
- [ ] Fuzzing/property-based tests where applicable

### 7.3 Maintainability
- [ ] No dead code or unused variables
- [ ] Modular structure (separate concerns)
- [ ] Constants are named, not magic numbers

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

## Audit Completion Checklist

Before finalizing the audit:

- [ ] All checklist items reviewed
- [ ] All findings documented with file:line references
- [ ] Severity assigned using rubric
- [ ] Remediation provided for each finding
- [ ] Verification tests designed
- [ ] Report follows template
