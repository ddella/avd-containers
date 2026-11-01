#!/usr/bin/env bash
# This script is intended to be run as root with a container that runs as root (even if you connect with a different user)
# However, it supports running as a user other than root if passwordless sudo is configured for that same user.

set -e 

sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}


# ** Start SSH server **
sudoIf /etc/init.d/ssh start 2>&1 | sudoIf tee /tmp/sshd.log > /dev/null

set +e
exec "$@"
