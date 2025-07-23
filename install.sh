#!/usr/bin/env bash

# Must be run as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

MODULE_NAME="docker_unix_socket"
MODULE_FILE="${MODULE_NAME}.te"
MODULE_PP="${MODULE_NAME}.pp"
MODULE_BZ2="${MODULE_PP}.bz2"
PACKAGE_DIR="/usr/share/selinux/packages"
MODULE_DIR="/usr/share/selinux/custom/${MODULE_NAME}"
MODULE_PATH="${MODULE_DIR}/${MODULE_FILE}"
POLICY_FILE='https://raw.githubusercontent.com/sghost13/selinux-docker-socket/refs/heads/main/docker_unix_socket.te'

command -v bzip2 >/dev/null 2>&1 || dnf install -y bzip2

# Create final module directory
mkdir -p "${MODULE_DIR}"
chown root:root "${MODULE_DIR}"
chmod 0755 "${MODULE_DIR}"
semanage fcontext -a -t selinux_config_t "${MODULE_DIR}(/.*)?"
chcon -u system_u "${MODULE_DIR}"
restorecon -R "${MODULE_DIR}"

# Create empty policy file and set correct ownership and context
touch "${MODULE_PATH}"
chown root:root "${MODULE_PATH}"
chmod 0644 "${MODULE_PATH}"
semanage fcontext -a -t selinux_config_t "${MODULE_PATH}"
chcon -u system_u "${MODULE_PATH}"
restorecon -R "${MODULE_PATH}"

# Download policy file
curl -fsSL "${POLICY_FILE}" -o "${MODULE_PATH}"

# Temporary build directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

# Build policy module
checkmodule -M -m -o "${TMP_DIR}/${MODULE_NAME}.mod" "${MODULE_PATH}"
semodule_package -o "${TMP_DIR}/${MODULE_PP}" -m "${TMP_DIR}/${MODULE_NAME}.mod"

# Install the module
semodule -i "${TMP_DIR}/${MODULE_PP}"

# Compress and install persistently
bzip2 -k -f "${TMP_DIR}/${MODULE_PP}"
install -m 0644 -o root -g root "${TMP_DIR}/${MODULE_BZ2}" "${PACKAGE_DIR}/"

BZ2_DEST="${PACKAGE_DIR}/${MODULE_BZ2}"
chcon system_u:object_r:modules_object_t:s0 "${BZ2_DEST}"
restorecon -v "${BZ2_DEST}"
semanage fcontext -a -t modules_object_t "${BZ2_DEST}" || true
