# AVD universal container

A small container image for working with [Arista AVD](https://avd.arista.com/). It has AVD, Ansible and the tools you need day to day already installed, so you can start building network configurations straight away.

It's a customised build of Arista's `ghcr.io/aristanetworks/avd/universal` image, rebuilt from one Dockerfile to be smaller. It installs AVD unmodified from [aristanetworks/avd](https://github.com/aristanetworks/avd).

## Quick start

Run this from your AVD project folder:

```bash
docker run -it --rm -v "$PWD":/workspace -w /workspace \
  ghcr.io/ddella/avd-containers/universal:python3.14-avd-v6.4.0
```

You land in a zsh prompt as the `avd` user, ready to run `ansible-playbook`. The user has UID 1000, so files you create are owned by UID 1000 on your machine.

## Tags

Tags follow the pattern `python<python-version>-avd-<avd-version>`:

| Tag | Platform |
|---|---|
| `python3.14-avd-v6.4.0` | `linux/amd64` and `linux/arm64`, selected automatically |
| `python3.14-avd-v6.4.0-amd64` | `linux/amd64` only |
| `python3.14-avd-v6.4.0-arm64` | `linux/arm64` only |

## What's included

| Component | Version |
|---|---|
| Debian | 13 (trixie), slim |
| Python | 3.14 |
| `pyavd` with Ansible extras | 6.4.0 |
| `arista.avd` collection | 6.4.0 |
| `ansible-core` | 2.21 |

The `arista.eos`, `ansible.netcommon` and `ansible.utils` collections are installed as dependencies.

**Tools:** `git`, `make`, `curl`, `wget`, `jq`, `less`, `nano`, `vim-tiny`, `htop`, `lsof`, `tree`, `rsync`, `unzip`, `xz-utils`, `procps`, `iproute2`, `net-tools`, `sudo`, an SSH client and server, and zsh with Oh My Zsh.

Debian packages, `pip` and `certifi` are upgraded each time the image is built.

## What's been left out

These parts of the upstream image were removed to save space:

- Docker-in-Docker, so you can't run `docker` commands inside the container.
- The `community.general` collection. To add it, run `ansible-galaxy collection install community.general`.
- Test files from the Ansible collections, and `ansible-test`.
- Tools such as `iptables`, `socat`, `strace`, `gpg`, `man` and `zip`. To add one, run `sudo apt-get update && sudo apt-get install <package>`.
- Locales other than `C.UTF-8`.

## Connecting over SSH

The SSH server listens on port 2222 and isn't started by default. This command starts it and logs in with your public key, so change the key path if yours is different:

```bash
docker run -d --name avd -p 2222:2222 \
  -v ~/.ssh/id_ed25519.pub:/home/avd/.ssh/authorized_keys:ro \
  ghcr.io/ddella/avd-containers/universal:python3.14-avd-v6.4.0 \
  /usr/local/share/ssh-init.sh sleep infinity

ssh -p 2222 avd@localhost
```

## Building it yourself

The image is built from [`containers/avd`](https://github.com/ddella/avd-containers/tree/main/containers/avd):

```bash
docker build --pull \
  --build-arg PYTHON_VERSION=3.14 \
  --build-arg AVD_VERSION=v6.4.0 \
  --tag avd-universal:local \
  containers/avd
```

The published images are built for each architecture on native runners by the [`container_build_native.yml`](https://github.com/ddella/avd-containers/blob/main/.github/workflows/container_build_native.yml) workflow.

## License

[Apache-2.0](https://github.com/ddella/avd-containers/blob/main/LICENSE), the same license as AVD.
