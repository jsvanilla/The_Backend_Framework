#!/bin/bash

# options to display
options=("FastApi (Python)" "NodeJS (Javascript)" "Cancel\n")


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
PROMT_MESSAGE='echo -e \n"\033[0mCHOOSE THE BACKEND ENVIRONMENT: "\n'

printf "\033[?25l\033[s"

# Prompt the user for a microservice name
echo -n \n"Enter a name for your microservice: "
read microservice_name

selected=0

# Display options
while true; do
    printf "\033[u\n"
    $PROMT_MESSAGE
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            printf "${GREEN}➤ ${options[$i]}${NC}\n"
        else
            printf "  ${options[$i]}\n"
        fi
    done

    # read user input
    read -s -n1 input

    # uptade selected option
    case $input in
        A) # Up Arrow
            if [ $selected -gt 0 ]; then
                selected=$((selected - 1))
            fi
            ;;
        B) # Down Arrow
            if [ $selected -lt $((${#options[@]} - 1)) ]; then
                selected=$((selected + 1))
            fi
            ;;
        "") # Enter
            option="${options[$selected]}"
            break
            ;;
        *) ;;
    esac
done

printf "\033[u\033[?25h"

clear

# Execute selected option
case $option in
    "${options[0]}")
        echo "Creating FastApi (Python) microservice $microservice_name ..."
        # Go to the services folder
        cd api/services && 
        mkdir $microservice_name &&
        cd $microservice_name
        # Create a virtual environment & install dependencies
        python3 -m venv venv &&
        source venv/bin/activate &&
        pip install --upgrade pip &&
        pip install fastapi uvicorn httpx pytest
        pip freeze > requirements.txt
        # Copying the template and creating the files
        file_content=$(cat ../../../templates/python/fastapi/basic_server.py)
        test_content=$(cat ../../../templates/python/fastapi/test_basic_server.py)
        dockerfile_content=$(cat ../../../templates/infraestructure/docker/fastapi_dockerfile)
        # Replacing the microservice_name string with the name of the microservice
        new_content=${file_content//microservice_name/$microservice_name}
        # this line get the same result that the line above. It's just a different way to do it
        new_test_content=${test_content//microservice_name/$(echo "$microservice_name")}
        # Creating the files
        echo "$new_content" > main.py
        echo "$new_test_content" > test_main.py
        echo "$dockerfile_content" > dockerfile
        ;;
    "${options[1]}")
        echo "Creating NodeJS (Javascript) microservice $microservice_name ..."
        # Javascript Commands
        ;;
    "${options[2]}")
        echo "Exiting..."
        ;;
    *) echo "Invalid Option";;
esac
