# ==========================================
# STAGE 0: Final stage
# ==========================================
FROM ghcr.io/ddella/avd-containers/avd6.4.0-python3.14:2026.11.9

ARG TARGETARCH
ARG GH_VERSION=2.103.3
ARG GLAB_VERSION=1.126.0
ARG AGE_VERSION=v1.3.2
ARG YQ_VERSION=v4.54.1
ARG YAMLLINT_VERSION=1.38.0
# Image version will be set by the build workflow
ARG IMAGE_VERSION

LABEL org.opencontainers.image.description="AVD image for Acme"
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.base.name="ghcr.io/ddella/avd-containers/avd6.4.0-python3.14:2026.11.9"

# Switch to root to perform admin tasks since inherit 'avd' user from the base image
USER root

### Special Python modules
# COPY requirements.txt /tmp/
# RUN pip3 install --no-cache-dir --upgrade pip \
#     && pip3 install --no-cache-dir -r /tmp/requirements.txt \
#     && pip3 install --no-cache-dir --upgrade certifi

# GitLab cli. glab adds 51 MB
# RUN curl -fsSLO "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb" \
#     && dpkg -i "glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb" \
#     && rm -f "glab_${GLAB_VERSION}_linux_${TARGETARCH}.deb"

# GitHub cli. gh adds 42 MB
RUN curl -fsSLO "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.deb" \
    && dpkg -i "gh_${GH_VERSION}_linux_${TARGETARCH}.deb" \
    && rm -f "gh_${GH_VERSION}_linux_${TARGETARCH}.deb"

# age cli
RUN curl -fsSLO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && tar -C /usr/local/bin --strip-components=1 --no-same-owner \
        -xzf "age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz" age/age age/age-keygen \
    && rm -f "age-${AGE_VERSION}-linux-${TARGETARCH}.tar.gz"

# yq
RUN curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" \
    && chmod +x /usr/local/bin/yq

### Install Private Root/SubRoot Certificates in Ubuntu OS store
COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Force Python/requests to use the OS trust store instead of its own built-in one
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Switch back to the Arista base image's 'avd' user 
USER avd

# Install 'yamllint'
RUN pip install --no-cache-dir --user "yamllint==${YAMLLINT_VERSION}"

# Also add the certificates to certifi, for sessions without the base image's ENV
RUN awk 1 /usr/local/share/ca-certificates/*.crt >> "$(python3 -m certifi)"

# Fix keyboard issue with vi
COPY --chown=avd:avd vimrc /home/avd/.vimrc

### ⛔ DO NOT ADD THE COMMAND 'ENTRYPOINT' ⛔, it will be inherited from the Arista base image
