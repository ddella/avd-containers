# ===========================================================================================
#           ‼️IMPORTANT‼️ ‼️IMPORTANT‼️ ‼️IMPORTANT‼️ ‼️IMPORTANT‼️
# ⚠️  WARNING: BUILD THIS IMAGE IN GITHUB ACTIONS OR GITLAB CI ONLY ⚠️
# The private Root/SubRoot certificates are installed at the END of this file, after every
# download (apt, curl, pip). Do not build this image locally, behind a firewall that's doing
# TLS inspection. The downloads will fail because the UTM certificate is not trusted yet.
# ===========================================================================================

# ==========================================
# STAGE 0: Final stage
# ==========================================
ARG BASE_IMAGE=ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
FROM ${BASE_IMAGE}

ARG TARGETARCH
# Base image name and digest for the OCI base image labels, set by the build workflow
ARG BASE_NAME=ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
ARG BASE_DIGEST
ARG GH_VERSION=latest
ARG GLAB_VERSION=latest
ARG AGE_VERSION=latest
ARG YQ_VERSION=latest
ARG BETTERLEAKS_VERSION=latest
# ARG BAO_VERSION=latest

# Image version and timestamp will be set by the build workflow
ARG IMAGE_VERSION
ARG RFC3339_TIMESTAMP

LABEL org.opencontainers.image.description="AVD image for ACME"
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
    && keyutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# GitLab cli. glab adds 51 MB
RUN if [ "$GLAB_VERSION" = latest ]; then \
        GLAB_VERSION=$(curl -fsSL https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest | jq -er '.tag_name'); \
    fi \
    && GLAB_VERSION="${GLAB_VERSION#v}" \
    && GLAB_DEB="glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb" \
    && GLAB_URL="https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads" \
    && echo "Installing glab ${GLAB_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "${GLAB_URL}/${GLAB_DEB}" \
    && curl -fsSL "${GLAB_URL}/checksums.txt" | grep " ${GLAB_DEB}$" | sha256sum -c - \
    && dpkg -i "${GLAB_DEB}" \
    && rm -f "${GLAB_DEB}" \
    && glab version

# GitHub cli. gh adds 42 MB
RUN if [ "$GH_VERSION" = latest ]; then \
        GH_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        https://github.com/cli/cli/releases/latest | sed 's#.*/##'); \
    fi \
    && GH_VERSION="${GH_VERSION#v}" \
    && GH_DEB="gh_${GH_VERSION}_linux_${TARGETARCH}.deb" \
    && GH_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}" \
    && echo "Installing gh ${GH_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "${GH_URL}/${GH_DEB}" \
    && curl -fsSL "${GH_URL}/gh_${GH_VERSION}_checksums.txt" | grep " ${GH_DEB}$" | sha256sum -c - \
    && dpkg -i "${GH_DEB}" \
    && rm -f "${GH_DEB}" \
    && gh --version

# age encryption cli adds 20 MB
# Options for checking the download: if you pin a fixed version, you can save its SHA-256 as a build arg
# and check it with echo "${AGE_SHA256} ${AGE_FILE}" | sha256sum -c -. That only works for a pinned version,
# not latest. Full sigsum checking is possible, but it adds a Go tool to the build.

RUN if [ "$AGE_VERSION" = latest ]; then \
        AGE_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        https://github.com/FiloSottile/age/releases/latest | sed 's#.*/##'); \
    fi \
    && AGE_VERSION="v${AGE_VERSION#v}" \
    && AGE_FILE="age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && echo "Installing age ${AGE_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${AGE_FILE}" \
    && tar -C /usr/local/bin --strip-components=1 --no-same-owner \
        -xzf "${AGE_FILE}" age/age age/age-keygen age/age-inspect age/age-plugin-pq \
    && rm -f "${AGE_FILE}" \
    && age --version

# yq YAML processor cli adds 16 MB
RUN if [ "$YQ_VERSION" = latest ]; then \
        YQ_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        https://github.com/mikefarah/yq/releases/latest | sed 's#.*/##'); \
    fi \
    && YQ_VERSION="v${YQ_VERSION#v}" \
    && YQ_BIN="yq_linux_${TARGETARCH}" \
    && YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}" \
    && echo "Installing yq ${YQ_VERSION} for ${TARGETARCH}" \
    && curl -fsSLO "${YQ_URL}/${YQ_BIN}" \
    && IDX=$(curl -fsSL "${YQ_URL}/checksums_hashes_order" | grep -nx 'SHA-256' | cut -d: -f1) \
    && YQ_SHA256=$(curl -fsSL "${YQ_URL}/checksums" | awk -v f="$((IDX + 1))" -v n="${YQ_BIN}" '$1 == n {print $f}') \
    && echo "${YQ_SHA256}  ${YQ_BIN}" | sha256sum -c - \
    && install -m 0755 "${YQ_BIN}" /usr/local/bin/yq \
    && rm -f "${YQ_BIN}" \
    && yq --version

# OpenBao cli adds 182 MB
# RUN if [ "$BAO_VERSION" = latest ]; then \
#         BAO_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
#         https://github.com/openbao/openbao/releases/latest | sed 's#.*/##'); \
#     fi \
#     && BAO_VERSION="v${BAO_VERSION#v}" \
#     && BAO_FILE="openbao_${BAO_VERSION#v}_linux_${TARGETARCH}.tar.gz" \
#     && BASE_URL="https://github.com/openbao/openbao/releases/download/${BAO_VERSION}" \
#     && echo "Installing OpenBao CLI ${BAO_VERSION} for ${TARGETARCH}" \
#     && curl -fsSLO "${BASE_URL}/${BAO_FILE}" \
#     && curl -fsSL "${BASE_URL}/checksums.txt" | grep " ${BAO_FILE}$" | sha256sum -c - \
#     && tar -C /usr/local/bin --no-same-owner -xzf "${BAO_FILE}" bao \
#     && rm -f "${BAO_FILE}" \
#     && bao version

# Betterleaks secret scanner adds 25 Mb
RUN if [ "$BETTERLEAKS_VERSION" = latest ]; then \
        BETTERLEAKS_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        https://github.com/betterleaks/betterleaks/releases/latest | sed 's#.*/##'); \
    fi \
    && BETTERLEAKS_VERSION="${BETTERLEAKS_VERSION#v}" \
    && case "${TARGETARCH}" in \
        amd64) DL_ARCH=x64 ;; \
        arm64) DL_ARCH=arm64 ;; \
            *) echo "Unsupported architecture for BetterLeaks: ${TARGETARCH}" >&2; exit 1 ;; \
        esac \
    && BL_FILE="betterleaks_${BETTERLEAKS_VERSION}_linux_${DL_ARCH}.tar.gz" \
    && BL_URL="https://github.com/betterleaks/betterleaks/releases/download/v${BETTERLEAKS_VERSION}" \
    && echo "Installing BetterLeaks v${BETTERLEAKS_VERSION} for ${TARGETARCH} (fetching ${DL_ARCH})" \
    && curl -fsSLO "${BL_URL}/${BL_FILE}" \
    && curl -fsSL "${BL_URL}/checksums.txt" | grep " ${BL_FILE}$" | sha256sum -c - \
    && tar -C /usr/local/bin --no-same-owner -xzf "${BL_FILE}" betterleaks \
    && rm -f "${BL_FILE}" \
    && betterleaks version

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
