# AVD container

A small container image for working with [Arista AVD](https://avd.arista.com/). AVD, Ansible and the tools you need day to day are already installed, so you can start building network configurations straight away.

It's a slimmed-down rebuild of Arista's `ghcr.io/aristanetworks/avd/universal` image, made from a single Dockerfile. AVD itself is installed unmodified from [aristanetworks/avd](https://github.com/aristanetworks/avd).

> [!NOTE]
> This is a personal community project. It is not affiliated with, endorsed by or supported by Arista Networks.

## Quick start

Pull the image:

```bash
docker pull ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
```

It's about 144 MB to download and 636 MB on disk.

Then run it from your AVD project folder:

```bash
docker run -it --rm -v "$PWD":/workspace -w /workspace \
  ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
```

You land in a zsh prompt as the `avd` user, ready to run `ansible-playbook`. The `avd` user has UID 1000, so files you create in `/workspace` are owned by UID 1000 on your machine.

## Images and tags

Each combination of AVD and Python is published as its own package, named `avd<avd-version>-python<python-version>`, for example `avd6.4.0-python3.12`. AVD 6.3.0, 6.4.0 and 6.5.0 are available, with Python 3.10 to 3.14.

Tags use `<year>.<month>.<build-number>`. The build number keeps increasing across months.

| Tag | Platform |
|---|---|
| `latest` | The most recent build, `linux/amd64` and `linux/arm64` |
| `2026.11.9` | `linux/amd64` and `linux/arm64`, selected automatically |
| `2026.11.9-amd64` | `linux/amd64` only |
| `2026.11.9-arm64` | `linux/arm64` only |

## What's included

| Component | Version |
|---|---|
| Debian | 13 (trixie), slim |
| Python | 3.10 to 3.14, depending on the image |
| `pyavd` with Ansible extras | Matches the image's AVD version |
| `arista.avd` collection | 6.3.0, 6.4.0 or 6.5.0 |
| `arista.eos` collection | 12.3.0 |
| `ansible.netcommon` collection | 8.7.1 |
| `ansible.utils` collection | 6.1.1 |
| `ansible-core` | 2.21 |

Only `arista.avd` is installed directly. The other collections come in as its dependencies, as declared in each collection's `galaxy.yml`:

```text
arista.avd 6.5.0
└── arista.eos >=12.2.0
    └── ansible.netcommon >=8.5.2
        └── ansible.utils >=3.0.0
```

**Tools:** `git`, `make`, `curl`, `wget`, `jq`, `less`, `nano`, `vim-tiny`, `htop`, `lsof`, `tree`, `rsync`, `unzip`, `xz-utils`, `procps`, `iproute2`, `net-tools`, `sudo`, an SSH client and server, and zsh with Oh My Zsh.

Debian packages, `pip` and `certifi` are upgraded every time the image is built.

## What's left out

These parts of the upstream image were removed to save space:

- **Docker-in-Docker.** You can't run `docker` commands inside the container.
- **The `community.general` collection.** AVD doesn't need it. If your own playbooks do, run `ansible-galaxy collection install community.general`.
- **Test files** from the Ansible collections, and `ansible-test`.
- **Tools** such as `iptables`, `socat`, `strace`, `gpg`, `man` and `zip`. To add one, run `sudo apt-get update && sudo apt-get install <package>`.
- **Locales** other than `C.UTF-8`.

## Connecting over SSH

The SSH server listens on port 2222 but isn't started by default. This command starts it and logs you in with your public key. Change the key path if yours is different:

```bash
docker run -d --name avd -p 2222:2222 \
  -v ~/.ssh/id_ed25519.pub:/home/avd/.ssh/authorized_keys:ro \
  ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest \
  /usr/local/share/ssh-init.sh sleep infinity

ssh -p 2222 avd@localhost
```

## Building it yourself

### Locally

The image is built from [`containers/avd`](https://github.com/ddella/avd-containers/tree/main/containers/avd):

```bash
docker build --pull \
  --build-arg PYTHON_VERSION=3.14 \
  --build-arg AVD_VERSION=v6.5.0 \
  --tag avd:local \
  containers/avd
```

### With GitHub Actions

The published images are built by the [`container_build_native.yml`](https://github.com/ddella/avd-containers/blob/main/.github/workflows/container_build_native.yml) workflow, on native amd64 and arm64 runners. Start a build and follow it with:

```bash
gh workflow run container_build_native.yml --ref main -f python_version=3.14 -f avd_version=v6.5.0
gh run watch
```

`python_version` accepts 3.10 to 3.14, and `avd_version` accepts `v6.3.0`, `v6.4.0` or `v6.5.0`.

> [!IMPORTANT]
> Python 3.15 isn't supported yet.

## Linting the Dockerfiles

[hadolint](https://github.com/hadolint/hadolint) checks Dockerfiles for common mistakes, and the shell code in `RUN` lines with ShellCheck. Run it with its Docker image from the root of the repository, so nothing needs to be installed:

```bash
cd "$(git rev-parse --show-toplevel)"
docker run --rm -v "$PWD":/work:ro -w /work hadolint/hadolint:v2.15.1 \
  hadolint --config .hadolint.yaml $(find . -name Dockerfile -not -path './.git/*')
```

The `cd` moves to the repository root first. Only the current folder is mounted, so from a subfolder hadolint couldn't see `.hadolint.yaml` or the other Dockerfiles.

The repository is mounted read-only, and `find` lists every file named `Dockerfile`. Each finding shows the file, line, rule and severity, for example:

```text
./containers/avd/Dockerfile:85 SC2016 info: Expressions don't expand in single quotes, use double quotes for that.
```

To lint a single file, give its path instead of the `find` command:

```bash
cd "$(git rev-parse --show-toplevel)"
docker run --rm -v "$PWD":/work:ro -w /work hadolint/hadolint:v2.15.1 \
  hadolint --config .hadolint.yaml containers/custom/acme/Dockerfile
```

### Ignored rules

Some rules flag choices this project makes on purpose. They're turned off in [`.hadolint.yaml`](https://github.com/ddella/avd-containers/blob/main/.hadolint.yaml), which the commands above pass with `--config`:

| Rule | What it flags | Why it's ignored |
|---|---|---|
| `DL3007` | `FROM` an image tagged `latest` | The ACME image always builds on the latest AVD image |
| `DL3008` | `apt-get install` without pinned versions | Debian packages are upgraded on every build |
| `DL3013` | `pip install` without pinned versions | `pip`, `certifi` and `yamllint` are kept up to date |
| `DL3066` | `USER` with a name instead of a numeric ID | The images use the named `avd` user, which exists in the image |

To ignore a rule for one run only, add `--ignore <rule>`, for example `hadolint --ignore SC2016 ...`. The full list of rules is in the [hadolint README](https://github.com/hadolint/hadolint#rules).

## License

[Apache-2.0](https://github.com/ddella/avd-containers/blob/main/LICENSE), the same license as AVD.
