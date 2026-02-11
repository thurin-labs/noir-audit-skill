# Noir Circuit Security Checklist

Use this checklist during manual review. For each item, actively search for vulnerabilities.

## 1. Constraint Completeness

### 1.1 Input Validation
- [ ] All public inputs are validated/constrained
- [ ] All private inputs have appropriate range checks
- [ ] Array indices are bounds-checked
- [ ] Optional/conditional values are properly handled

### 1.2 Business Logic Constraints
- [ ] Every business rule has a corresponding `assert()` or constraint
- [ ] Conditional logic (`if/else`) properly constrains all branches
- [ ] Loop iterations are bounded and deterministic
- [ ] Return values are constrained, not just computed

### 1.3 Underconstraint Detection
- [ ] Can any private input be changed without invalidating the proof?
- [ ] Are there "free" variables that aren't constrained?
- [ ] Do all code paths lead to proper constraints?
- [ ] Are intermediate values used in final constraints?

**Test**: For each private input, ask "What happens if I change this value?"

## 2. Field Arithmetic Safety

### 2.1 Overflow/Underflow
- [ ] Addition operations checked for field overflow
- [ ] Subtraction operations checked for underflow (wrap-around)
- [ ] Multiplication checked for overflow
- [ ] Division by zero prevented

### 2.2 Range Checks
- [ ] Integer values have explicit bounds: `assert(x.lt(256))`
- [ ] Timestamps are within reasonable ranges
- [ ] Amounts/balances are non-negative where required
- [ ] Indices are within array bounds

### 2.3 Field Element Assumptions
- [ ] Code doesn't assume values fit in u64/u128 without checks
- [ ] Comparison operations account for field wrapping
- [ ] Bit operations use appropriate integer types

**Test**: Try values near field modulus, zero, and max expected values.

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

**Common pattern**:
```noir
let nullifier = poseidon2([user_secret, event_id, context]);
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
| Missing `assert()` | Can invalid input pass? | Soundness break |
| Field overflow | `a + b` where both are large | Incorrect arithmetic |
| Missing range check | Is `x < 256` enforced? | Type confusion |
| Public leak | Is `pub` intentional? | Privacy break |
| Weak nullifier | Hash of small domain? | Brute-forceable |
| No domain separation | Same hash for different uses? | Collision attacks |
| Unbound proof | Proof works for any address? | Authorization bypass |

## Audit Completion Checklist

Before finalizing the audit:

- [ ] All checklist items reviewed
- [ ] All findings documented with file:line references
- [ ] Severity assigned using rubric
- [ ] Remediation provided for each finding
- [ ] Verification tests designed
- [ ] Report follows template
