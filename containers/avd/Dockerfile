ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}-slim-trixie

# RFC3339 time to set label
ARG RFC3339_TIMESTAMP
# Image version will be set by the build workflow
ARG IMAGE_VERSION
# AVD release to install
ARG AVD_VERSION=v6.4.0

# set labels
LABEL org.opencontainers.image.description="AVD universal image with pre-installed AVD collection. The image is still in preview and under active development."
LABEL com.arista.license_terms="https://github.com/aristanetworks/avd/blob/devel/LICENSE"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.authors="Arista PS Daniel Della-Noce <daniel.dellanoce@arista.com>"
LABEL org.opencontainers.image.url="https://github.com/ddella/avd-containers"
LABEL org.opencontainers.image.documentation="https://avd.arista.com/"
LABEL org.opencontainers.image.created=${RFC3339_TIMESTAMP}
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.vendor="Arista Networks"
# VS Code settings: the remote user, the script that starts sshd and the extensions to install.
LABEL devcontainer.metadata='[{"remoteUser":"avd"},{"entrypoint":"/usr/local/share/ssh-init.sh"},{"customizations":{"vscode":{"extensions":["ms-python.python","ms-python.vscode-pylance","mechatroner.rainbow-csv","oderwat.indent-rainbow","pomdtr.excalidraw-editor"]}}}]'

# set ANSIBLE_CONFIG to ansible.cfg in local directory
# this is required to address Ansible ignoring config in a world writable directory
# on Codespaces, Gitlab Runner, etc.
ENV ANSIBLE_CONFIG="ansible.cfg"
ENV PATH=$PATH:/home/avd/.local/bin

# Add entrypoint script and the script that starts sshd.
COPY ./entrypoint.sh /bin/entrypoint.sh
COPY ./ssh-init.sh /usr/local/share/ssh-init.sh

# Install tools, then create the avd user and configure sshd.
RUN chmod +x /bin/entrypoint.sh /usr/local/share/ssh-init.sh \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    make \
    git \
    # xz-utils required for docker import to work
    xz-utils \
    zsh \
    sudo \
    openssh-client \
    openssh-server \
    curl \
    wget \
    jq \
    less \
    nano \
    vim-tiny \
    procps \
    iproute2 \
    net-tools \
    lsof \
    htop \
    tree \
    rsync \
    unzip \
    && PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir --no-compile --upgrade pip \
    && groupadd -g 1000 avd \
    && groupadd -f ssh \
    && useradd -m -u 1000 -g 1000 -G ssh -s /bin/zsh avd \
    && echo "avd ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/avd \
    && chmod 0440 /etc/sudoers.d/avd \
    && sed -i -E 's/^#?Port .*/Port 2222/; s/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# Switch user to avd otherwise Ansible will be installed as root.
USER avd

# Install Oh My Zsh with only the git plugin, then the Ansible AVD collection.
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && rm -rf ~/.oh-my-zsh/.git \
    && find ~/.oh-my-zsh/plugins -mindepth 1 -maxdepth 1 ! -name git -exec rm -rf {} + \
    && printf '%s\n' 'export ZSH="$HOME/.oh-my-zsh"' 'ZSH_THEME="devcontainers"' 'plugins=(git)' \
        "zstyle ':omz:update' mode disabled" 'source $ZSH/oh-my-zsh.sh' > ~/.zshrc \
    && echo 'source $HOME/.profile' > ~/.zprofile \
    && pip install --no-cache-dir "pyavd[ansible] @ git+https://github.com/aristanetworks/avd.git@${AVD_VERSION}#subdirectory=python-avd" \
    && ansible-galaxy collection install "git+https://github.com/aristanetworks/avd.git#/ansible_collections/arista/avd/,${AVD_VERSION}" \
    && pip install --no-cache-dir --upgrade certifi \
    && rm -rf ~/.cache ~/.ansible/galaxy_cache \
        ~/.ansible/collections/ansible_collections/*/*/tests \
        ~/.local/lib/python3*/site-packages/ansible_test \
        ~/.local/bin/ansible-test

# Add the prompt theme from the devcontainers common-utils feature.
COPY --chown=avd:avd ./devcontainers.zsh-theme /home/avd/.oh-my-zsh/custom/themes/devcontainers.zsh-theme

# Use ENTRYPOINT instead of CMD to ensure that entryscript is always executed.
ENTRYPOINT [ "/bin/entrypoint.sh" ]
CMD []
