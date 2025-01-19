#!/usr/bin/env bash

#1st argument: Environment file
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

_temp_file="${_SCRIPT_DIR}/${_DISPATCHER_FILE}"

echo -ne \
'#!/bin/bash\n\n' > ${_temp_file}

echo -ne \
"source $1\n" >> ${_temp_file}

echo -ne \
'
iface=$1
action=$2

if [[ "$action" == "up" ]]; then
	"$UTM_LOGIN_BIN" -username="$_UTM_USERNAME" -password="$_UTM_PASSWORD"
fi

' >> ${_temp_file}

sudo chmod 755 ${_temp_file}

if [[ ! -d ${_DISPATCHER_DIR} ]]; then
  echo -ne "Dispatcher directory: ${_DISPATCHER_DIR} does not exist\n"
  exit 1
fi

#Copy the dispatcher script to dispatcher dir
sudo cp "${_temp_file}" "${_DISPATCHER_DIR}/${_DISPATCHER_FILE}" 

sudo systemctl restart NetworkManager.service

rm ${_temp_file}

exit 0