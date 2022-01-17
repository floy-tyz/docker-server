#!/bin/bash

SUCCESS='\033[1;32m'
WARNING='\033[1;33m'
ERROR='\033[0;31m'
NC='\033[0m'

DOCKER_ENGINE_DIR="/var/www/docker-engine"
DOCKER_PROJECT_DIR="/var/www"

Help()
{
   echo
   echo "options:"
   echo "-n     set project name (folder name)"
   echo "-p     set project directory (full path)"
   echo "-g     set docker-engine directory (full path)"
   echo
}

while getopts "n:p:g:" option; do
    case $option in
        n)
            NAME=$OPTARG
            DOCKER_PROJECT_DIR=$DOCKER_PROJECT_DIR"/$NAME/docker"
            ;;
        p)
            DOCKER_PROJECT_DIR=$OPTARG
            ;;
        g)
            DOCKER_ENGINE_DIR=$OPTARG
            ;;
        \?)
           Help
           printf "${ERROR}Error: Invalid option${NC}\n"
           exit;;
    esac
done

if [ ! -d "$DOCKER_PROJECT_DIR" ] || [ ! -f "$DOCKER_PROJECT_DIR/docker-compose.yaml" ]; then
    printf "${ERROR}Your project is not defined ${NC}\n"
    exit
fi

if [ ! -d "$DOCKER_ENGINE_DIR" ] || [ ! -f "$DOCKER_ENGINE_DIR/docker-compose.yaml" ]; then
    printf "${WARNING}Docker engine is not installed, if you get access:\n${SUCCESS}https://github.com/Floy-Tyz/docker-engine.git\n${WARNING}otherwise ${ERROR}go fuck your self${NC}\n"
    exit
fi

printf "\n${SUCCESS}Project - $DOCKER_PROJECT_DIR${NC}\n"
printf "${SUCCESS}Engine - $DOCKER_ENGINE_DIR${NC}\n"

sh $DOCKER_ENGINE_DIR/start/compose.sh $DOCKER_PROJECT_DIR &
sh $DOCKER_ENGINE_DIR/start/compose.sh $DOCKER_ENGINE_DIR &
sudo docker stats