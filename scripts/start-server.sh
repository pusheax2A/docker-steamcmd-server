#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

if [ ! -z "${WS_CONTENT}" ]; then
	echo "---Installing Workshop Content with ID('s): ${WS_CONTENT}---"
	${STEAMCMD_DIR}/steamcmd.sh \
	+@sSteamCmdForcePlatformType windows \
	+force_install_dir ${SERVER_DIR} \
	+login anonymous \
	+workshop_download_item 3017310 ${WS_CONTENT// / +workshop_download_item 3017310  } \
	+quit
fi

echo "---Prepare Server---"
echo "---Looking for config files---"
if [ ! -d ${SERVER_DIR}/WS/Saved/Config/WindowsServer ]; then
	if [ ! -d ${SERVER_DIR}/ConanSandbox ]; then
    	echo "-----------------------------------------------------------"
    	echo "---Something went wrong can't find folder 'ConanSandbox'---"
    	echo "--------------Putting Server into sleep mode---------------"
    	sleep infinity
    	fi
    if [ ! -d ${SERVER_DIR}/WS/Saved ]; then
		mkdir ${SERVER_DIR}/WS/Saved
    fi
	if [ ! -d ${SERVER_DIR}/WS/Saved/Config ]; then
		mkdir ${SERVER_DIR}/WS/Saved/Config
    fi
    if [ ! -d ${SERVER_DIR}/WS/Saved/Config/WindowsServer ]; then
		mkdir ${SERVER_DIR}/WS/Saved/Config/WindowsServer
    fi
fi
if [ ! -f ${SERVER_DIR}/WS/Saved/Config/WindowsServer/Engine.ini ]; then
	echo "---'Engine.ini' not found, downloading template---"
    cd ${SERVER_DIR}/WS/Saved/Config/WindowsServer
	if wget -q -nc --show-progress --progress=bar:force:noscroll https://github.com/pusheax2A/docker-steamcmd-server/soulmask/config/Engine.ini ; then
		echo "---Sucessfully downloaded 'Engine.ini'---"
	else
		echo "---Something went wrong, can't download 'Engine.ini', putting server in sleep mode---"
		sleep infinity
	fi
else
	echo "---'Engine.ini' found---"
fi
export WINEARCH=win64
export WINEPREFIX=/serverdata/serverfiles/WINE64
echo "---Checking if WINE workdirectory is present---"
if [ ! -d ${SERVER_DIR}/WINE64 ]; then
	echo "---WINE workdirectory not found, creating please wait...---"
    mkdir ${SERVER_DIR}/WINE64
else
	echo "---WINE workdirectory found---"
fi
echo "---Checking if WINE is properly installed---"
if [ ! -d ${SERVER_DIR}/WINE64/drive_c/windows ]; then
	echo "---Setting up WINE---"
    cd ${SERVER_DIR}
    winecfg > /dev/null 2>&1
    sleep 15
else
	echo "---WINE properly set up---"
fi
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${SERVER_DIR}/WSServer.exe.exe -log ${GAME_PARAMS}