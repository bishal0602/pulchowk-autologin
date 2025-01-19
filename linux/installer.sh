#!/usr/bin/env bash

echo -ne "\nInstaller Script for Pulchowk Campus Captive Portal\n"

echo -ne "#################################\n\n"

#Get architecture of computer
declare -A archs

archs=(\
	["i386"]="386"\
	["x86_64"]="amd64"\
	["arm"]="arm"\
	["aarch64"]="arm64"\
)

_user_arch=$(uname -m)
_matched_arch=${archs["$_user_arch"]}

if [[ -z ${_matched_arch} ]]; then
	echo -ne "Your architecture is ${_user_arch} which is not supported by our script\n"
	exit 1
else
	echo -ne "Proceeding with ${_user_arch}.....\n\n"
fi


#Define URLs for Download
############# link for binary file

_target_binary_link="https://dist.bishal0602.com.np/pcampus/bin/utm_login-linux-${_matched_arch}"

####################################

######### Links for other scripts

_scheduler_link="https://dist.bishal0602.com.np/pcampus/scheduler.sh"
_unscheduler_link="https://dist.bishal0602.com.np/pcampus/unscheduler.sh"

####################################


#Define PATHS for LOGIN SCRIPTS
_script_dir="${HOME}/.pulchowk_utm_login"
_env_file="${_script_dir}/.env"

_binary_path="${_script_dir}/utm_login"
_scheduler_path="${_script_dir}/scheduler.sh"
_unscheduler_path="${_script_dir}/unscheduler.sh"

if [[ ! -d ${_script_dir} ]]; then
	echo -ne "Creating directory: ${_script_dir}\n\n"
	mkdir -p ${_script_dir}
else
	echo -ne "${_script_dir} directory already exists.\n\n"
fi

#Clear the environment file
echo -ne "" > $_env_file

#Export Scripts Directory
echo "export _SCRIPT_DIR='${_script_dir}'" >> $_env_file
echo "export UTM_LOGIN_BIN='${_binary_path}'" >> $_env_file

#Function for downloading file
download_file(){

	local _path="$1"
	local _download_link="$2"

	curl -s -o "${_path}" "${_download_link}"
	echo $?

}


#Download the scripts and binaries required
echo -ne "Downloading UTM_login binary...\n"
_status=$(download_file $_binary_path $_target_binary_link)
if [[ ! $_status -eq 0 ]]; then
	echo -ne "Download failed for UTM_login binary.\n"
	exit 1
else
	echo -ne "Successfully downloaded UTM_login binary.\n"
fi
sudo chmod 755 $_binary_path

echo -ne "Downloading Scheduler script...\n"
_status=$(download_file $_scheduler_path $_scheduler_link)
if [[ ! $_status -eq 0 ]]; then
	echo -ne "Download failed for Scheduler script.\n"
	exit 1
else
	echo -ne "Successfully downloaded Scheduler script.\n"
fi
sudo chmod 755 $_scheduler_path


echo -ne "Downloading Unscheduler script...\n"
_status=$(download_file $_unscheduler_path $_unscheduler_link)
if [[ ! $_status -eq 0 ]]; then
	echo -ne "Download failed for Unscheduler script.\n"
	exit 1
else
	echo -ne "Successfully downloaded Unscheduler script.\n"
fi
sudo chmod 755 $_unscheduler_path


#Get username and password from user

echo -ne "\nEnter Campus Login Username: "
read _UTM_USERNAME

echo -ne "Enter Campus Login Password: "
read -s _UTM_PASSWORD

echo -ne "\n\n"

echo "export _UTM_USERNAME='${_UTM_USERNAME}'" >> ${_env_file}
echo "export _UTM_PASSWORD='${_UTM_PASSWORD}'" >> ${_env_file}


#Run the scheduler script

#Install network manager, then start and enable services (background processes)

echo -ne "Installing network-manager...\n\n"
sudo apt-get -y install network-manager
echo -ne "\n"
if [[ $? -eq 0 ]]; then
	echo -ne "Successfully installed network-manager\n\n"
else
	echo -ne "Installation of network-manager failed\n"
	exit 1
fi

echo -ne "Starting NetworkManager.service...\n"
sudo systemctl start NetworkManager.service
if [[ $? -eq 0 ]]; then
	echo "Successfully started NetworkManager.service\n"
else
	echo "Starting of NetworkManager.service failed\n"
	exit 1
fi
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
if [[ $? -eq 0 ]]; then
	echo "Successfully enabled NetworkManager.service\n"
else
	echo "Enabling NetworkManager.service failed\n"
	exit 1
fi

echo -ne "\n"

echo -ne "Starting NetworkManager-dispatcher.service...\n"
sudo systemctl start NetworkManager-dispatcher.service
if [[ $? -eq 0 ]]; then
	echo -ne "Successfully started NetworkManager-dispatcher.service\n"
else
	echo -ne "Starting of NetworkManager-dispatcher.service failed\n"
	exit 1
fi
sudo systemctl enable NetworkManager-dispatcher.service
if [[ $? -eq 0 ]]; then
	echo -ne "Successfully enabled NetworkManager-dispatcher.service\n"
else
	echo -ne "Enabling NetworkManager-dispatcher.service failed\n"
	exit 1
fi


_DISPATCHER_FILE="99-pulchowk-utm-login"
_DISPATCHER_DIR="/etc/NetworkManager/dispatcher.d"

echo "export _DISPATCHER_FILE='${_DISPATCHER_FILE}'" >> ${_env_file}
echo "export _DISPATCHER_DIR='${_DISPATCHER_DIR}'" >> ${_env_file}

sudo "${_scheduler_path}" "${_env_file}"

if [[ $? -eq 0 ]]; then
	echo -ne "\n#########################\n\n"
	echo -ne "Successful Setup of AutoLogin script\n"
	echo -ne "\n#########################\n\n"
	exit 0
else
	echo -ne "\n#########################\n\n"
	echo -ne "Problem with Scheduler script...\n"
	echo -ne "Setup failed\n"
	echo -ne "\n#########################\n\n"
	exit 1
fi