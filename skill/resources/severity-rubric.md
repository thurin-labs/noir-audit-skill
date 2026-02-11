# Severity Classification Rubric

Use this rubric to consistently classify findings by severity.

## Severity Matrix

| Severity | Impact | Likelihood | Examples |
|----------|--------|------------|----------|
| **Critical** | Catastrophic | Likely/Certain | Proof forgery, complete soundness break |
| **High** | Significant | Possible | Privacy leak of sensitive data, nullifier collision |
| **Medium** | Limited | Requires conditions | Partial privacy leak, edge case failures |
| **Low** | Minimal | Unlikely | Best practice violations, theoretical issues |
| **Info** | None | N/A | Code quality, documentation, optimization |

## Detailed Criteria

### Critical

**Definition**: Complete break of a core ZK security property.

**Impact indicators**:
- Attacker can forge proofs for false statements (soundness break)
- Any user can impersonate any other user
- Nullifiers can be bypassed entirely
- Private keys or secrets can be extracted

**Likelihood indicators**:
- Exploitable with minimal effort
- No special conditions required
- Affects all users/proofs

**Action**: Block deployment. Do not use this circuit.

**Examples**:
- Missing signature verification allows any proof
- Underconstrained nullifier allows proof reuse
- Private input not constrained, can be set arbitrarily

---

### High

**Definition**: Significant security degradation or privacy breach.

**Impact indicators**:
- Sensitive private data is leaked to verifiers
- Nullifier collision possible under realistic conditions
- Authorization can be bypassed in some cases
- Completeness broken for legitimate users

**Likelihood indicators**:
- Exploitable with moderate effort
- Requires some setup but realistic
- Affects many users or high-value scenarios

**Action**: Must fix before mainnet deployment.

**Examples**:
- Private age value can be brute-forced from public hash
- Nullifier only uses low-entropy inputs
- Proof not bound to user address

---

### Medium

**Definition**: Limited security impact or requires specific conditions.

**Impact indicators**:
- Partial privacy leak (non-sensitive data)
- Edge case failures affect small user subset
- Theoretical attack with impractical requirements
- Defense-in-depth violation

**Likelihood indicators**:
- Requires specific conditions to exploit
- Affects edge cases, not typical usage
- Attacker needs significant resources

**Action**: Should fix before mainnet. Acceptable to defer with documented risk.

**Examples**:
- Field overflow possible with values > 2^200
- Privacy leak only affects users with specific attribute combination
- Missing range check on value that's validated elsewhere

---

### Low

**Definition**: Best practice violation or minor issue.

**Impact indicators**:
- No direct security impact currently
- Could become issue if code changes
- Increases audit/maintenance burden
- Theoretical concern with no practical exploit

**Likelihood indicators**:
- Very unlikely to be exploited
- Requires unrealistic conditions
- Defense-in-depth concern only

**Action**: Consider fixing. Document if not fixed.

**Examples**:
- Missing domain separation (but no current collision vector)
- Unused constraint that doesn't affect security
- Overly permissive range check (128-bit when 64-bit sufficient)

---

### Informational

**Definition**: Not a security issue, but worth noting.

**Content types**:
- Code quality improvements
- Documentation suggestions
- Gas/constraint optimization opportunities
- Deviation from best practices (non-security)
- Positive observations ("this is done well")

**Action**: Optional. Provided for completeness.

**Examples**:
- Variable naming could be clearer
- Consider adding comments for complex logic
- Could reduce constraint count by restructuring
- Test coverage could be improved

---

## ZK-Specific Considerations

When evaluating severity for ZK circuits, consider:

### Soundness vs Privacy vs Completeness

| Property Broken | Typical Severity |
|-----------------|------------------|
| Soundness | Critical (proofs can be forged) |
| Privacy | High-Medium (depends on data sensitivity) |
| Completeness | Medium-Low (legitimate users affected) |

### Privacy Leak Assessment

| Leaked Data | Typical Severity |
|-------------|------------------|
| Private key / secret | Critical |
| Identity (name, SSN) | High |
| Sensitive attribute (exact age, address) | High |
| Non-sensitive attribute (state, boolean) | Medium |
| Metadata (timing, count) | Low-Medium |

### Attack Complexity

| Complexity | Severity Adjustment |
|------------|---------------------|
| No special access needed | +1 level |
| Requires on-chain transaction | No change |
| Requires off-chain coordination | -1 level |
| Requires >$100k resources | -1 level |
| Purely theoretical | -2 levels (max Low) |

## Severity Disagreement

If severity is unclear:

1. Default to the **lower** severity (conservative)
2. Document the reasoning in the finding
3. Note conditions that would change severity
4. Let the client make the final risk decision

## Examples by Category

### Underconstraint Examples

| Finding | Severity | Reasoning |
|---------|----------|-----------|
| Private input completely unconstrained | Critical | Proof forgery possible |
| One of three inputs unconstrained | High | Partial forgery |
| Edge case input unconstrained | Medium | Limited scenarios |

### Privacy Leak Examples

| Finding | Severity | Reasoning |
|---------|----------|-----------|
| SSN derivable from public output | Critical | Catastrophic privacy breach |
| Exact age derivable (18-100 brute force) | High | Sensitive data leaked |
| State code derivable | Medium | Non-sensitive, intentional in some cases |
| Boolean flag leaked | Low | Minimal information |

### Nullifier Examples

| Finding | Severity | Reasoning |
|---------|----------|-----------|
| Nullifier can be set arbitrarily | Critical | Complete bypass |
| Same nullifier for different events | High | Cross-event replay |
| Nullifier collision at 2^64 scale | Low | Impractical to exploit |
