# #!/usr/bin/env bash

# Copyright (C) 2021 Uco Mesdag
# Description:  Installer for the podman-vagrant command, a command for setting
#               up and managing a podman machine with Vagrant for use with
#               podman-remote.

VAGRANT2PODMAN_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Iterate over PATH to look for a writable directory
IFS=':'
for DIR in $PATH; do
  if [ -w "$DIR" ] && ! echo $WRITABLE_PATH | egrep -q "(^|;)$DIR($|;)"; then
    WRITABLE_PATH="${WRITABLE_PATH#;*};${DIR}"
  fi
done

if [ -z ${WRITABLE_PATH+x} ]; then
  echo "No writable directory found in your PATH."
  echo "Add a writable directory in your PATH or run again with sudo."
  exit 1
fi

# Prompt to select an install destination
IFS=';'
PS3="Select where in your PATH you want to install the \"podman-vagrant\" command: "
select INSTALL_PATH in $WRITABLE_PATH
do
  if [ -z $INSTALL_PATH ]; then
    echo "Please choose where in your PATH to install."
  else
    echo "Installing the \"podman-vagrant\" command in \"$INSTALL_PATH\"."
    break
  fi
done
unset IFS

cat > "$INSTALL_PATH/podman-vagrant" <<EOF
#!/usr/bin/env bash

# Copyright (C) 2021 Uco Mesdag
# Description:  Command for setting up and managing a podman machine with Vagrant
#               for use with podman-remote.

usage() {
  echo "Usage:    \$(basename "\$0") COMMAND [arg...]"
  echo
  echo "Commands:"
  echo "  start             starts and provisions the podman vagrant environment"
  echo "  stop              suspends the podman machine"
  echo "  env               display the commands to set up the environment for podman"
  echo "  ip                display the ip of the podman machine"
  echo "  ssh               connects to the podman machine via SSH"
  echo "  ssh-config        outputs SSH configuration to connect to the podman machine"
  echo "  scp               copies data into the podman machine via SCP"
  echo "  status            outputs status of the podman machine"
  echo "  destroy           stops and deletes all traces of the podman vagrant machine"
  echo "  uninstall         remove this podman-vagrant command"
}

export VAGRANT_CWD="$VAGRANT2PODMAN_PATH"

env() {
  SSHCONFIG=\$(vagrant --color ssh-config)
  if [ \$? == 0 ]; then
    PORT=\$( echo \$SSHCONFIG | sed 's/.*\sPort\s\([0-9]\+\)\s.*/\1/' )
    PRIVKEY=\$( echo \$SSHCONFIG | sed 's/.*\sIdentityFile\s\(.\+\)\sIdentitiesOnly.*/\1/' )

    echo "export CONTAINER_HOST=ssh://vagrant@127.0.0.1:\$PORT/run/podman/podman.sock;"
    echo "export CONTAINER_SSHKEY=\$PRIVKEY;"

    echo "# Run this command to configure your shell:"
    echo "# eval \\\$(podman-vagrant env)"
  else
    echo -n "\$SSHCONFIG"
    exit 1
  fi
}

ip() {
  IPADRESSES=\$(vagrant ssh -- hostname -I)
  for IP in \$(echo \$IPADRESSES | tac -s' '); do
    ping -ot 1 \$IP >/dev/null 2>&1 && echo \$IP && exit 0
  done
  echo "no reachable ip address found"
  echo
  echo "you can try SSH tunneling, e.g.:"
  echo "  podman-vagrant ssh -L 8080:localhost:8080 -N &"
  exit 1
}

ssh() {
  if [ -z \$CONTAINER_HOST ]; then
    echo "# Run this command to configure your shell first:"
    echo "# eval \\\$(podman-vagrant env)"
    exit 1
  fi

  HOST=\$(echo \$CONTAINER_HOST | sed 's/^ssh:\/\/\(.\+\)@\([0-9\.]\+\):\([0-9]\+\)\/.*$/\2/')
  PORT=\$(echo \$CONTAINER_HOST | sed 's/^ssh:\/\/\(.\+\)@\([0-9\.]\+\):\([0-9]\+\)\/.*$/\3/')
  USER=\$(echo \$CONTAINER_HOST | sed 's/^ssh:\/\/\(.\+\)@\([0-9\.]\+\):\([0-9]\+\)\/.*$/\1/')

  $(which ssh) \$HOST -l \$USER -p \$PORT -i $CONTAINER_SSHKEY \$@
}

# Check if Vagrant is installed
if ! which vagrant >/dev/null 2>&1; then
  echo "vagrant is not installed."
  exit 1
fi

# Check if Podman is installed
if ! which podman >/dev/null 2>&1 && ! which podman-remote >/dev/null 2>&1; then
  echo "podman is not installed."
  exit 1
fi

# Check if vagrant2podman exists
if [ ! -z "$VAGRANT2PODMAN_PATH" ] && [ ! -d "$VAGRANT2PODMAN_PATH" ]; then
  echo "path \"$VAGRANT2PODMAN_PATH\" does not exist."
  exit 1
fi

while true; do
   case "\$@" in
    start) vagrant up ; exit \$? ;;
    stop) vagrant suspend; exit \$? ;;
    env) env; exit \$? ;;
    ip) ip; exit \$? ;;
    ssh-config) vagrant ssh-config; exit \$? ;;
    ssh*) ssh \${@:2}; exit \$? ;;
    scp*) vagrant scp \${@:2}; exit \$? ;;
    status) vagrant status; exit \$? ;;
    destroy|destroy*-f) vagrant destroy \$2; exit \$? ;;
    uninstall) rm "\$0"; exit \$? ;;
    *) usage ; exit 1 ;;
  esac
done
EOF

chmod +x "$INSTALL_PATH/podman-vagrant"
echo "Done."
