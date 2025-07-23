# SELinux Policy: `docker_unix_socket`

This repository provides a minimal SELinux policy module that allows confined containers (under the `container_t` domain) to access the Docker UNIX socket through an intermediary such as the [docker socket proxy](https://docs.linuxserver.io/images/docker-socket-proxy/).

## Purpose

In systems where SELinux is enforced, direct communication between confined containers and the Docker UNIX socket (`/var/run/docker.sock`) is blocked by default. This policy module:

- Allows `container_t` processes to connect to `container_runtime_t` labeled UNIX stream sockets.
- Grants write access to `container_var_run_t`-labeled socket files.

These permissions are sufficient to enable interaction with Docker through a controlled proxy such as the docker socket proxy, without fully disabling SELinux protections or relabeling the socket.

This policy is intended to be as minimal and scoped as possible, granting only the specific access required for this use case.

## Installation

To build and install the policy module on a rhel/fedora system with SELinux enabled:

```bash
curl -fsSL https://raw.githubusercontent.com/sghost13/selinux-docker-socket/main/install.sh | bash
```
