#!/usr/bin/env bash

# Copyright (C) 2021 Uco Mesdag
# Description:  Installer for the podman-vagrant command, a command for setting
#               up and managing a podman machine with Vagrant for use with
#               podman-remote.

# Get the current directory
VAGRANT2PODMAN_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Iterate over PATH to look for a writable directory
IFS=':'
for DIR in $PATH; do
  if [ -w "$DIR" ] && ! echo $WRITABLE_PATH | egrep -q "(^|;)$DIR($|;)"; then
    WRITABLE_PATH="${WRITABLE_PATH#;*};${DIR}"
  fi
done

# Exit when no writable directory was found
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

# Set the path and write the script to the install destination
VAGRANT2PODMAN_PATH=$VAGRANT2PODMAN_PATH envsubst '$VAGRANT2PODMAN_PATH' < podman-vagrant.tmpl > "$INSTALL_PATH/podman-vagrant"

# Make the script executable
chmod +x "$INSTALL_PATH/podman-vagrant"

echo "Done."
