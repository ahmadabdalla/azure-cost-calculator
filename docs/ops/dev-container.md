# Dev Container Operations Guide

## What it does

Provides a reproducible Ubuntu Linux environment for running and validating the Bash and PowerShell scripts, their unit tests, and Waza eval tasks locally. Particularly useful for catching Linux-specific bugs (e.g. `ARG_MAX` / `MAX_ARG_STRLEN` crashes) that don't surface on macOS.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or compatible container runtime)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## How to use

1. Open the repository in VS Code.
2. When prompted, click **Reopen in Container**, or run the command palette action `Dev Containers: Reopen in Container`.
3. VS Code builds the image (first run only) and opens a shell at `/workspace`.
4. Run bats tests:
   ```bash
   bash tests/unit/run-bats-tests.sh
   ```
5. Run PowerShell (Pester) tests:
   ```bash
   pwsh tests/unit/Run-PesterTests.ps1
   ```
6. Run a script directly against the live Azure API:
   ```bash
   bash skills/azure-cost-calculator/scripts/get-azure-pricing.sh \
     --service-name "Virtual Machines" --arm-sku-name "Standard_E2as_v5" \
     --region "uaenorth" --output-format Table
   ```
7. Validate eval task schemas:
   ```bash
   waza check
   ```
8. Run evals (requires `COPILOT_GITHUB_TOKEN` with "Copilot Requests" permission):
   ```bash
   waza run --tags "service:<service-name>" --output results/results.json
   ```

## Container details

| Item               | Value                                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------------------------ |
| Base image         | `ubuntu:24.04`                                                                                               |
| Tools              | `ca-certificates`, `curl`, `jq`, `git`, `nodejs`, `npm`, `bash`, `pwsh`                                      |
| bats version       | `1.11.1` (matches CI; see `.github/scripts/test/install-bats.sh`)                                            |
| Pester version     | `5.7.1` (matches CI; see `.github/scripts/test/Install-Pester.ps1`)                                          |
| PSScriptAnalyzer   | `1.24.0` (matches CI; see `.github/scripts/test/Install-Pester.ps1`)                                         |
| waza version       | `v0.38.0` (matches CI; see `.github/actions/install-waza/action.yml`)                                        |
| Workspace          | `/workspace` (bind-mounted from `localWorkspaceFolder`)                                                      |
| User               | `ubuntu` (UID/GID 1000; built into `ubuntu:24.04`; auto-remapped to host UID/GID on Linux by Dev Containers) |
| VS Code extensions | `shellcheck`, `shell-format`                                                                                 |

## Making changes

- **Adding tools**: edit `.devcontainer/Dockerfile` and rebuild the container (`Dev Containers: Rebuild Container`).
- **Upgrading the base image**: update the `FROM ubuntu:XX.XX` tag in `Dockerfile` and the "Base image" entry in this doc together.
- **Pinning bats**: keep the version in `Dockerfile` in sync with `.github/scripts/test/install-bats.sh`.
- **Upgrading waza**: update the version tag in the `RUN curl` step in `Dockerfile` to match `.github/actions/install-waza/action.yml`, then rebuild the container.
- **VS Code settings/extensions**: edit `.devcontainer/devcontainer.json`.

## Troubleshooting

- **Container fails to build**: ensure Docker is running and you have network access to pull `ubuntu:24.04` and npm packages.
- **bats not found after rebuild**: the `npm install -g bats@1.11.1` step requires network; check Docker's DNS/proxy settings.
- **waza not found after rebuild**: the Dockerfile downloads the waza binary during image build. Ensure Docker has outbound HTTPS access to `github.com`.
- **File permission errors on Linux**: the `ubuntu` user's UID/GID is automatically remapped to the host user's UID/GID by Dev Containers (`updateRemoteUserUID`). If you still see permission errors, ensure only one regular user exists in the image and that `remoteUser` is set to a non-root user in `devcontainer.json`.

## External references

- [VS Code Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Add a non-root user to a container](https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user)
- [bats-core releases](https://github.com/bats-core/bats-core/releases)
- [Waza releases](https://github.com/microsoft/waza/releases)
