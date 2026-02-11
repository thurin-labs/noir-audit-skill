# Noir Circuit Audit Skill

A [Claude Code](https://claude.ai/claude-code) skill for security auditing Noir zero-knowledge circuits.

## Features

- Structured audit methodology for ZK circuits
- Comprehensive security checklist (based on [OpenZeppelin's guide](https://www.openzeppelin.com/news/developer-guide-to-building-safe-noir-circuits))
- ZK-specific vulnerability categories
- Severity classification rubric
- Professional report template

## Installation

```bash
# Clone the repo
git clone https://github.com/thurinlabs/noir-audit-skill
cd noir-audit-skill

# Run the install script
./install.sh
```

This creates symlinks in `~/.claude/skills/`.

## Usage

After installation, restart Claude Code and use:

```
# Full audit
/noir-audit

# Focused audit
/noir-audit Focus on nullifier security
/noir-audit Check for privacy leaks
/noir-audit Review src/main.nr
```

Or just ask naturally:
- "Audit my Noir circuits"
- "Check this circuit for underconstraints"
- "Review the privacy of my ZK proof"

## What It Checks

### Constraint Issues
- Underconstrained values
- Missing assertions
- Overconstrained proofs

### Field Arithmetic
- Overflow/underflow in finite fields
- Missing range checks
- Integer type assumptions

### Privacy
- Accidental public inputs
- Correlation leaks
- Brute-forceable hashes

### Nullifiers
- Uniqueness and determinism
- Identity binding
- Collision resistance

### Cryptography
- Domain separation
- Signature verification
- Hash function usage

## Files

```
noir-audit-skill/
├── skill/
│   ├── SKILL.md              # Main audit methodology (creates /noir-audit command)
│   └── resources/
│       ├── checklist.md      # Security checklist
│       ├── severity-rubric.md # Severity classification
│       └── report-template.md # Report format
├── install.sh
├── uninstall.sh
├── README.md
└── LICENSE
```

## Uninstall

```bash
./uninstall.sh
```

## References

- [OpenZeppelin: Building Safe Noir Circuits](https://www.openzeppelin.com/news/developer-guide-to-building-safe-noir-circuits)
- [Nethermind: Deep Dive into Noir](https://www.nethermind.io/blog/our-first-deep-dive-into-noir-what-zk-auditors-learned)
- [Noir Documentation](https://noir-lang.org/docs/)

## License

MIT
