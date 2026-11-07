ARG FROM_IMAGE
ARG FROM_VARIANT

FROM ${FROM_IMAGE}:${FROM_VARIANT}

# RFC3339 time to set label
ARG RFC3339_TIMESTAMP
# Image version will be set by the build workflow
ARG IMAGE_VERSION
# Full image name, for example ghcr.io/ddella/avd-containers/avd6.5.0-python3.14:latest
ARG IMAGE_NAME
# set labels
LABEL org.opencontainers.image.title="AVD container"
LABEL org.opencontainers.image.description="Personal community image with Arista AVD pre-installed. Not affiliated with or supported by Arista Networks."
LABEL org.opencontainers.image.authors="Daniel Della-Noce"
LABEL org.opencontainers.image.vendor="Daniel Della-Noce"
LABEL org.opencontainers.image.url="https://github.com/ddella/avd-containers"
LABEL org.opencontainers.image.source="https://github.com/ddella/avd-containers"
LABEL org.opencontainers.image.documentation="https://github.com/ddella/avd-containers"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.created=${RFC3339_TIMESTAMP}
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL io.github.ddella.avd.license_terms="https://github.com/aristanetworks/avd/blob/devel/LICENSE"
LABEL io.github.ddella.avd.image=${IMAGE_NAME}

ARG PYAVD_INSTALL_LOCATION
ARG ANSIBLE_INSTALL_LOCATION
ARG USERNAME

# Switch user to given USERNAME otherwise Ansible will be installed as root.
USER ${USERNAME}
ENV PATH=$PATH:/home/${USERNAME}/.local/bin

RUN pip install --no-cache-dir "pyavd[ansible] @ ${PYAVD_INSTALL_LOCATION}" \
    && ansible-galaxy collection install ${ANSIBLE_INSTALL_LOCATION} \
    # install community.general to support callback plugins in ansible.cfg, etc.
    # && ansible-galaxy collection install community.general \
    && pip install --no-cache-dir --upgrade certifi \
    && rm -rf ~/.cache ~/.ansible/galaxy_cache \
        ~/.ansible/collections/ansible_collections/*/*/tests \
        ~/.local/lib/python3*/site-packages/ansible_test \
        ~/.local/bin/ansible-test
