#!/bin/zsh

# ==============================================================================
# DevContainer Update Checker
# Compares the creation timestamp of the latest pulled base image against the 
# currently running container to alert the user if a rebuild is necessary.
# ==============================================================================

# Dynamically pull the IMAGE variable directly from the devcontainer.json
DEV_JSON=".devcontainer/devcontainer.json"
# Strip // comments using sed, then extract the raw string value of .image
# Caveat: You can use the multiline comment: /* ... */
IMAGE=$(sed 's|//.*||g' "$DEV_JSON" | jq -r '.image')

# IMAGE="ghcr.io/nxt-ACME-com/avd-6.4.0-py3.14:latest"

# Safety check: ensure jq successfully found the image property
if [ -z "$IMAGE" ] || [ "$IMAGE" = "null" ]; then
  echo -e "\033[1;31m ❌ ERROR: Could not parse the 'image' property from $DEV_JSON \033[0m"
  exit 1
fi

# ------------------------------------------------------------------------------
# Retrieve Image Metadata
# We compare the 'org.opencontainers.image.created' OCI label instead of the 
# raw 'Image ID' because 👉VS Code dynamically modifies the image at runtime👈
# to inject Dev Container features, which changes the container's local ID.
# ------------------------------------------------------------------------------

# Get the creation timestamp from the freshly pulled image
LATEST_TIME=$(sudo docker inspect -f '{{index .Config.Labels "org.opencontainers.image.created"}}' $IMAGE 2>/dev/null)
# Get the creation timestamp from the currently running Dev Container
# (Inside a Dev Container, $HOSTNAME inherently resolves to the container's short ID)
# ⛔ Don't change the $HOSTNAME ⛔
CURRENT_TIME=$(sudo docker inspect -f '{{index .Config.Labels "org.opencontainers.image.created"}}' $HOSTNAME 2>/dev/null)

# echo "LATEST_TIME:  [$LATEST_TIME]"
# echo "CURRENT_TIME: [$CURRENT_TIME]"

# Compare the IDs and print a loud warning if they mismatch
if [ -n "$LATEST_TIME" ] && [ -n "$CURRENT_TIME" ] && [ "$LATEST_TIME" != "$CURRENT_TIME" ]; then
  echo -e "\n\033[1;41m\033[1;37m ============================================================ \033[0m"
  echo -e "\033[1;33m ⚠️  IMAGE UPDATE DETECTED: A newer version was pulled.        \033[0m"
  echo -e "\033[1;33m    Please run 'Dev Containers: Rebuild Container' to apply.  \033[0m"
  echo -e "\033[1;33m  Image build time:     ${LATEST_TIME}  \033[0m"
  echo -e "\033[1;33m  Container build time: ${CURRENT_TIME}  \033[0m"
  echo -e "\033[1;41m\033[1;37m ============================================================ \033[0m\n"
else
  echo -e "\n\033[1;42m\033[1;37m ============================================================ \033[0m"
  echo -e "\033[1;32m ✅  IMAGE IS UP TO DATE.                                     \033[0m"
  echo -e "\033[1;32m     Image build time:     ${LATEST_TIME}                     \033[0m"
  echo -e "\033[1;32m     Container build time: ${CURRENT_TIME}                    \033[0m"
  echo -e "\033[1;42m\033[1;37m ============================================================ \033[0m\n"
fi
