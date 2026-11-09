# ==========================================
# ⚠️  WARNING: BUILD THIS IMAGE IN GITHUB ACTIONS OR GITLAB CI ONLY ⚠️
# The private Root/SubRoot certificates are installed at the END of this file, after every
# download (apt, curl, pip). Behind the firewall UTM, which inspects TLS traffic, those downloads
# fail because the UTM certificate is not trusted yet. Do not build this image locally behind the UTM.
# ==========================================
# STAGE 0: Final stage
# ==========================================
# AVD base image. The build workflow passes the image pinned by digest (name@sha256:...),
# so amd64 and arm64 use the same base. Local builds use this default.
ARG BASE_IMAGE=ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
FROM ${BASE_IMAGE}

ARG TARGETARCH
# Base image name and digest for the OCI base image labels, set by the build workflow
ARG BASE_NAME=ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
ARG BASE_DIGEST
# Tool versions. "latest" looks up the newest release at build time.
# The build workflow passes the exact versions, so amd64 and arm64 get the same ones.
# gh and glab versions have no leading "v", age and yq versions keep it, for example v1.3.2.
ARG GH_VERSION=latest
ARG GLAB_VERSION=latest
ARG AGE_VERSION=latest
ARG YQ_VERSION=latest
# Image version and timestamp will be set by the build workflow
ARG IMAGE_VERSION
ARG RFC3339_TIMESTAMP

LABEL org.opencontainers.image.description="AVD image for Acme"
LABEL org.opencontainers.image.base.name=${BASE_NAME}
LABEL org.opencontainers.image.base.digest=${BASE_DIGEST}
LABEL com.acme.image.created=${RFC3339_TIMESTAMP}
LABEL com.acme.image.version=${IMAGE_VERSION}

# Switch to root to perform admin tasks since inherit 'avd' user from the base image
USER root

# pipefail, so a failed version lookup stops the build instead of giving an empty version
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

### Upgrade the OS, then install special Debian packages. Replace the example packages with the ones you need.
# The upgrade also brings the latest public root CAs from the 'ca-certificates' package.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        keyutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# GitLab cli. glab adds 51 MB
RUN if [ "$GLAB_VERSION" = latest ]; then \
        GLAB_VERSION=$(curl -fsSL https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest | jq -er '.tag_name | ltrimstr("v")'); \
    fi \
    && echo "Installing glab ${GLAB_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb" \
    && dpkg -i "glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb" \
    && rm -f "glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb"

# GitHub cli. gh adds 42 MB
RUN if [ "$GH_VERSION" = latest ]; then \
        GH_VERSION=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | jq -er '.tag_name | ltrimstr("v")'); \
    fi \
    && echo "Installing gh ${GH_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.deb" \
    && dpkg -i "gh_${GH_VERSION}_linux_${TARGETARCH}.deb" \
    && rm -f "gh_${GH_VERSION}_linux_${TARGETARCH}.deb"

# age encryption cli
RUN if [ "$AGE_VERSION" = latest ]; then \
        AGE_VERSION=$(curl -fsSL https://api.github.com/repos/FiloSottile/age/releases/latest | jq -er '.tag_name'); \
    fi \
    && echo "Installing age ${AGE_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && tar -C /usr/local/bin --strip-components=1 --no-same-owner \
        -xzf "age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz" age/age age/age-keygen age/age-inspect \
    && rm -f "age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz"

# yq cli
RUN if [ "$YQ_VERSION" = latest ]; then \
        YQ_VERSION=$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -er '.tag_name'); \
    fi \
    && echo "Installing yq ${YQ_VERSION} for ${TARGETARCH}" \
    && curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" \
    && chmod +x /usr/local/bin/yq

### Install Private Root/SubRoot Certificates in Debian OS store.
# Done after every download, see the WARNING at the top of this file.
COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Force Python/requests to use the OS trust store instead of its own built-in one
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Switch back to the AVD base image's 'avd' user
USER avd

# Install the latest 'yamllint'
RUN pip install --no-cache-dir --user --upgrade yamllint

### Special Python modules, installed as 'avd' in ~/.local like AVD and its certifi in the base image.
# Upgrading 'certifi' gets the latest public root CAs. The private certificates are added
# to certifi just below, after every pip install.
# COPY requirements.txt /tmp/
# RUN pip install --no-cache-dir --user -r /tmp/requirements.txt \
#     && pip install --no-cache-dir --user --upgrade certifi

# Also add the certificates to certifi, for sessions without the base image's ENV.
# Keep this after every pip install, upgrading 'certifi' would replace cacert.pem.
RUN awk 1 /usr/local/share/ca-certificates/*.crt >> "$(python3 -m certifi)"

# Fix keyboard issue with vi
COPY --chown=avd:avd vimrc /home/avd/.vimrc

### ⛔ DO NOT ADD THE COMMAND 'ENTRYPOINT' ⛔, it will be inherited from the AVD base image
