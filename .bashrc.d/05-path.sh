# Keep repository utilities available in interactive shells.
dot_bin="$HOME/.dot/bin"
case ":$PATH:" in
  *":$dot_bin:"*) ;;
  *) PATH="$dot_bin:$PATH" ;;
esac
export PATH
unset dot_bin

# Lazydocker uses Podman's Docker-compatible API socket.
lazydocker() {
  local runtime_dir=${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}
  DOCKER_HOST="unix://${runtime_dir}/podman/podman.sock" command lazydocker "$@"
}
