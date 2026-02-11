# Audit Report Template

Use this template for the final audit report.

---

# {Project Name} Circuit Security Audit

**Audit Date**: {YYYY-MM-DD}
**Auditor**: {Name/Organization}
**Commit**: {git commit hash}

---

## Executive Summary

### Scope

| Item | Value |
|------|-------|
| Repository | {repo URL} |
| Commit | {hash} |
| Circuits Reviewed | {list of .nr files} |
| Total Constraints | {approximate count} |
| Noir Version | {version from Nargo.toml} |
| Backend | {Barretenberg, etc.} |

### Findings Summary

| Severity | Count |
|----------|-------|
| Critical | {n} |
| High | {n} |
| Medium | {n} |
| Low | {n} |
| Informational | {n} |

### Overall Assessment

{2-3 paragraph summary of:
- What the circuit does
- Overall security posture
- Key concerns or positive observations
- Recommendation (deploy / fix issues first / do not deploy)}

---

## Circuit Overview

### Purpose

{Describe what the circuit proves and its use case}

### Architecture

```
{Diagram or description of circuit structure}
```

### Inputs and Outputs

#### Public Inputs
| Name | Type | Description |
|------|------|-------------|
| {name} | {Field/u32/etc} | {what it represents} |

#### Private Inputs
| Name | Type | Description |
|------|------|-------------|
| {name} | {Field/u32/etc} | {what it represents} |

#### Public Outputs
| Name | Type | Description |
|------|------|-------------|
| {name} | {Field/u32/etc} | {what it represents} |

### Cryptographic Primitives

| Primitive | Usage | Implementation |
|-----------|-------|----------------|
| {e.g., Poseidon2} | {nullifier computation} | {stdlib or custom} |
| {e.g., ECDSA P-256} | {signature verification} | {stdlib} |

---

## Assumptions and Trust Model

### Trusted Components

- {e.g., IACA certificates are authentic}
- {e.g., Backend (Barretenberg) is correctly implemented}

### Out of Scope

- {e.g., Smart contract integration}
- {e.g., Frontend/SDK code}
- {e.g., Key management}

### Limitations

- {e.g., Audit based on commit X, changes after not reviewed}
- {e.g., No formal verification performed}

---

## Findings

### Summary Table

| ID | Title | Severity | Status | Category |
|----|-------|----------|--------|----------|
| {N-01} | {title} | {Critical/High/Medium/Low/Info} | {Open/Resolved} | {category} |

---

### {N-01}: {Finding Title}

**Severity**: {Critical / High / Medium / Low / Informational}

**Category**: {Underconstraint / Privacy / Arithmetic / Nullifier / Crypto / Logic}

**Location**: `{file}:{line-range}`

#### Description

{Detailed description of the vulnerability}

#### Impact

{What can go wrong? Which ZK property is affected (soundness/privacy/completeness)?}

#### Proof of Concept

```noir
// Code or steps demonstrating the issue
{example code or attack steps}
```

#### Remediation

{Specific fix recommendation}

```noir
// Suggested fix
{corrected code}
```

#### Verification Test

```noir
#[test]
fn test_finding_n01_fixed() {
    // Test that verifies the fix
}
```

#### Status

{Open / Resolved / Acknowledged}

{If resolved: "Fixed in commit {hash}"}

---

## Recommendations

### Immediate Actions

1. {Fix critical/high findings before deployment}
2. {Add specific tests}

### Future Improvements

1. {Consider adding...}
2. {Monitor for...}

### Testing Recommendations

| Test Type | Coverage | Recommendation |
|-----------|----------|----------------|
| Unit tests | {X%} | {Add tests for...} |
| Negative tests | {X%} | {Test invalid inputs...} |
| Edge cases | {X%} | {Test boundary values...} |
| Fuzzing | {Yes/No} | {Consider property-based testing} |

---

## Appendix

### A. Files Reviewed

| File | Lines | Constraints (approx) |
|------|-------|---------------------|
| `src/main.nr` | {n} | {n} |
| `src/utils.nr` | {n} | {n} |

### B. Tools Used

- Noir {version}
- Barretenberg {version}
- {any other tools}

### C. References

- [OpenZeppelin: Building Safe Noir Circuits](https://www.openzeppelin.com/news/developer-guide-to-building-safe-noir-circuits)
- [Noir Documentation](https://noir-lang.org/docs/)
- {project-specific references}

---

## Disclaimer

This audit is not a guarantee of security. It represents a best-effort review at a point in time. Smart contracts and zero-knowledge circuits are experimental technology. Users should exercise caution and perform their own due diligence.

---

**Report Generated**: {date}
