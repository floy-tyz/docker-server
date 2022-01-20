#!/bin/bash

SUCCESS='\033[1;32m'
WARNING='\033[1;33m'
ERROR='\033[0;31m'
NC='\033[0m'

cd $1
sudo docker-compose -p $2 up --build >> /dev/null
