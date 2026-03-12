# Docker Testbed

A local Ubuntu environment for catching Linux-specific issues and simulating the end-user skill install experience on Ubuntu.

## What it does

Two modes:

| Mode | Script | Purpose |
|------|--------|---------|
| Test runner | `tests/docker/run-tests.sh` | Runs the full bats unit test suite inside an Ubuntu container. Catches issues that don't surface on macOS (e.g. `ARG_MAX` per-argument size limits, GNU vs BSD tool differences). |
| Skill simulation | `tests/docker/run-skill-sim.sh` | Creates a fresh workspace, installs the published skill via `npx`, and drops into an interactive shell. Validates the end-user install experience on Ubuntu. |

The Docker image (`tests/docker/Dockerfile`) is based on `ubuntu:latest` and pins `bats@1.11.1` to match CI exactly.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
  - macOS: `brew install --cask docker`, then launch Docker Desktop once
- Internet access (for pulling the base image and installing packages)

## Usage

### Run the bats test suite on Ubuntu

```bash
# Run all tests
bash tests/docker/run-tests.sh

# TAP output (same format as CI)
bash tests/docker/run-tests.sh --tap

# Run a single test file
bash tests/docker/run-tests.sh tests/unit/bash/lib/invoke-retail-prices-query.bats
```

The repo is mounted as a volume — the container always runs against your current local branch with no rebuild required after code changes. The image only needs to be rebuilt when the `Dockerfile` changes (the script handles this automatically).

### Simulate skill install on Ubuntu

```bash
bash tests/docker/run-skill-sim.sh
```

This installs the **published skill from the `main` branch** via `npx`. Use this to validate the end-user install experience, not to test local changes.

Once inside the container shell, scripts are available at:

```bash
.claude/skills/azure-cost-calculator/scripts/get-azure-pricing.sh
.claude/skills/azure-cost-calculator/scripts/explore-azure-pricing.sh
```

### Reproduce a Linux-specific bug

To run a script directly against the live API from inside Ubuntu:

```bash
docker run --rm -it \
    -v "$(pwd):/repo" \
    azure-cost-testbed \
    bash skills/azure-cost-calculator/scripts/explore-azure-pricing.sh \
        --service-name 'Virtual Machines' --search-term 'Easv5' --region 'uaenorth'
```

## How to make changes

### Updating the base image or dependencies

Edit `tests/docker/Dockerfile`. The run scripts always rebuild the image before running, so changes take effect on the next invocation.

### Pinning bats to a new version

Update the `RUN npm install -g bats@...` line in `Dockerfile` to match the version in `.github/scripts/test/install-bats.sh`. Keep these in sync.

### Adding packages to the image

Add them to the `apt-get install` block in the `Dockerfile`.

## Troubleshooting

**`docker: command not found`** — Docker Desktop is not installed or not running. Install via `brew install --cask docker` and launch the app.

**`permission denied` on run scripts** — Make the scripts executable: `chmod +x tests/docker/*.sh`

**Build fails on `npm install -g bats`** — Check the version in `.github/scripts/test/install-bats.sh` and ensure the `Dockerfile` matches.

**Tests pass locally but fail in Docker** — This is expected for Linux-specific issues and is the point of the testbed. Check the error against known gotchas (GNU vs BSD `sed`, `ARG_MAX` per-argument limits, locale-sensitive `tr`).

## External references

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [bats-core](https://github.com/bats-core/bats-core)
- [Ubuntu Docker image](https://hub.docker.com/_/ubuntu)
