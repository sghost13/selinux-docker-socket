# SELinux Policy: `docker_unix_socket`

This repo contains an SELinux policy module and an install script. The custom policy enables confined containers to mount UNIX domain sockets—such as `/var/run/docker.sock`—into container volumes. This is required for containers like [Traefik](https://doc.traefik.io/traefik/providers/docker/), [Portainer](https://docs.portainer.io/admin/docker/docker-sock), [Watchtower](https://containrrr.dev/watchtower/arguments/#-v-varrundockersockvarrundockersock), [Dozzle](https://dozzle.dev/), and similar tools that interact with the Docker API.

You should use an intermediary like [docker socket proxy](https://docs.linuxserver.io/images/docker-socket-proxy/) to reduce risk when exposing the Docker socket.

Example volume mount:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro,Z
```

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
