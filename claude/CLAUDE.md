# Global CLAUDE.md

Guidance for Claude Code across all projects.

## About Me

I work on scientific computing and machine learning for the SNO+ particle physics experiment. My projects involve deep learning (PyTorch), Snakemake pipelines, and distributed computing on HTCondor clusters.

## Python Stack

- **Python 3.13**, managed with `uv` 
- **Linting/formatting**: `ruff check` and `ruff format` — run before committing
- **Line length**: 120 characters
- **Pre-commit hooks**:  ruff, typos, trailing whitespace, YAML/TOML checks

## Code Style

- Prefer clear, direct code over defensive abstractions
- No speculative generalization — solve the problem at hand
- No docstrings or comments added to code I didn't change
- No error handling for scenarios that can't happen
- Keep helpers inline unless they're reused in multiple places
- Use keyword arguments unless function has one or two arguments


## Common Commands

```bash
# Python env (uv projects)
uv sync --locked

# Lint + format
ruff check . && ruff format .

```

## Environment

- Container runtime: Apptainer/Singularity (`.sif` images)
- W&B for experiment tracking (entity: `scottdegraw`)
- Machine-specific environment details are in `~/.claude/CLAUDE.local.md`, imported below

## Git

- Commit messages should explain *why*, not just *what*
- Keep commits focused; one logical change per commit
- Do not amend published commits

## Plotting

- Use latex commands when working with matplotlib
 

@~/.claude/CLAUDE.local.md
