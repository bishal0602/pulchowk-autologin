#!/usr/bin/env bash

# Fisrt argument: environment file
if [ -z "$1" ]; then
  echo -ne "Error: No environment file provided.\n"
  echo -ne "Usage: $0 <environment_file>\n"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo -ne "Error: Environment file '$1' does not exist.\n"
  exit 1
fi

source $1

sudo rm "${_DISPATCHER_DIR}/${_DISPATCHER_FILE}" 

if [[ ! $? -eq 0 ]]; then
  echo -ne "Unable to remove the dispatcher script.\n"
  exit 1
fi

sudo systemctl restart NetworkManager.service

echo -ne "\nSuccessfully removed the login dispatcher script\n"

exit 0