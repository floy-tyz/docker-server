#!/bin/bash

SUCCESS='\033[1;32m'
WARNING='\033[1;33m'
ERROR='\033[0;31m'
NC='\033[0m'

DOCKER_ENGINE_DIR="/var/www/docker-engine"
DOCKER_PROJECT_DIR="/var/www"

RESTART_ENGINE=0
RESTART_PROJECT=0

Help()
{
    echo "Usage: dockerin [options] [-n] <name> ..."
    echo
    echo "  -h          show this help"
    echo "  -n <name>   set project name (folder name)"
    echo "  -p <path>   set project directory (full path)"
    echo "  -e <path>   set docker-engine directory (full path)"
    echo "  -r          restart engine"
    echo "  -b          restart project"
    echo
}

# : in start - silent mode
# : after option - need arguments => -n some-value-is-required
# -b => boot lol

while getopts ":n:p:e:rhb" option; do
    case $option in
        n)
            NAME=$OPTARG
            DOCKER_PROJECT_DIR=$DOCKER_PROJECT_DIR"/$NAME/docker"
            ;;
        p)
            DOCKER_PROJECT_DIR=$OPTARG
            ;;
        e)
            DOCKER_ENGINE_DIR=$OPTARG
            ;;
        r)
            RESTART_ENGINE=1
            ;;
        b)
            RESTART_PROJECT=1
            ;;
        h)
            Help
            exit;;
        \?)
            printf "\n${ERROR}Error: '$OPTARG' Invalid option${NC}\n"
            Help
            exit;;
    esac
done

if [ ! -d "$DOCKER_PROJECT_DIR" ] || [ ! -f "$DOCKER_PROJECT_DIR/docker-compose.yaml" ]; then
    printf "${ERROR}Your project or docker-compose is not defined ${NC}\n"
    printf "${ERROR}$DOCKER_PROJECT_DIR${NC}\n"
    exit
fi

if [ ! -d "$DOCKER_ENGINE_DIR" ] || [ ! -f "$DOCKER_ENGINE_DIR/docker-compose.yaml" ]; then
    printf "${WARNING}Docker engine is not installed, if you get access:\n${SUCCESS}https://github.com/Floy-Tyz/docker-engine.git\n${WARNING}otherwise ${ERROR}go fuck your self${NC}\n"
    exit
fi

if [ $RESTART_ENGINE -eq 1 ]; then
    for name in nginx-proxy mysql adminer
    do
        if [ "$(sudo docker ps -a -q -f name=$name)" ]; then
            if [ "$( sudo docker container inspect -f '{{.State.Running}}' $name )" == "true" ]; then
                printf "${WARNING}Container $name is already running${NC}\n"
                sudo docker stop $name
            fi
            if [ "$(sudo docker ps -aq -f status=exited -f name=$name)" ]; then
                printf "${WARNING}$name restarting...${NC}\n"
                sudo docker rm $name
            fi
        fi
    done
fi

if [ $RESTART_PROJECT -eq 1 ]; then
    CONTAINERS=$(sudo docker ps -a -q -f name=course)
    for CONTAINER in $CONTAINERS
    do
        if [ "$( sudo docker container inspect -f '{{.State.Running}}' $CONTAINER )" == "true" ]; then
            printf "${WARNING}Container $CONTAINER is already running${NC}\n"
            sudo docker stop $CONTAINER
        fi
        if [ "$(sudo docker ps -aq -f status=exited -f id=$CONTAINER)" ]; then
            sudo docker rm $CONTAINER
            printf "${WARNING}$CONTAINER restarting...${NC}\n"
        fi
    done
fi

printf "\n${SUCCESS}Project - $DOCKER_PROJECT_DIR${NC}\n"
printf "${SUCCESS}Engine - $DOCKER_ENGINE_DIR${NC}\n"

if [ $RESTART_ENGINE -eq 1 ]; then
    bash $DOCKER_ENGINE_DIR/start/compose.sh $DOCKER_PROJECT_DIR $NAME &
    bash $DOCKER_ENGINE_DIR/start/compose.sh $DOCKER_ENGINE_DIR $NAME &
    sudo docker stats
fi

if [ $RESTART_ENGINE -eq 0 ]; then
    bash $DOCKER_ENGINE_DIR/start/compose.sh $DOCKER_PROJECT_DIR $NAME &
    sudo docker stats
fi