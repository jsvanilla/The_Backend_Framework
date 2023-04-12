#!/bin/bash

# options to display
options=("FastApi (Python)" "Express (Javascript)" "NestJS (Javascript)" "Actix (Rust)" "Cancel\n")


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
PROMT_MESSAGE='echo -e \n"\033[0mCHOOSE THE BACKEND ENVIRONMENT: "\n'

printf "\033[?25l\033[s"

# Prompt the user for a microservice name
echo -n "Enter a name for your microservice: "
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



function move_to_microservice_folder() {
    cd api/services && 
    mkdir $microservice_name &&
    cd $microservice_name
}

function update_docker_compose() {
    docker_compose_route="../../docker-compose.yml"
    if ! grep -q "[^[:space:]]" "$docker_compose_route"; then
        docker_compose_new_content=$(cat ../../templates/infraestructure/docker/docker-compose-new-template.yml)
        new_docker_compose_content=${docker_compose_new_content//microservice_name/$microservice_name}
        echo "$new_docker_compose_content" > "$docker_compose_route"
    else
        current_port=$(cat "../../../templates/infraestructure/docker/docker_current_port.txt")
        new_port=$((current_port + 1))
        echo "$new_port" > "../../../templates/infraestructure/docker/docker_current_port.txt"
        docker_compose_add_content=$(cat ../../templates/infraestructure/docker/docker-compose-add-container.txt)
        new_port_docker_compose=${docker_compose_add_content//$current_port/$new_port}
        new_docker_compose_add_content=${new_port_docker_compose//microservice_name/$microservice_name}
        echo "$new_docker_compose_add_content" >> "$docker_compose_route"
        # update dockerfile
        dockerfile_content=$(cat dockerfile)
        new_dockerfile_content=${dockerfile_content//$current_port/$new_port}
        echo "$new_dockerfile_content" > dockerfile
    fi
}

# Execute selected option
case $option in
    "${options[0]}")
        echo "Creating FastApi (Python) microservice $microservice_name ..."
        move_to_microservice_folder
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
        update_docker_compose
        printf "\n${GREEN} ${microservice_name} was succesfully created!\n"
        ;;
    "${options[1]}")
        echo "Creating NodeJS (Javascript) microservice $microservice_name ..."
        move_to_microservice_folder
        # Initialize package.json and install dependencies
        npm init -y &&
        npm install express &&
        npm install --save-dev nodemon
        # Copying the template and creating the files
        file_content=$(cat ../../../templates/javascript/express/basic_server.js)
        dockerfile_content=$(cat ../../../templates/infraestructure/docker/nodejs_dockerfile)
        # Replacing the microservice_name string with the name of the microservice
        new_content=${file_content//microservice_name/$microservice_name}
        # Creating the files
        echo "$new_content" > index.js
        echo "$dockerfile_content" > dockerfile
        # Add "start" script to package.json
        sed -i 's/"scripts": {/"scripts": {\n    "start": "nodemon index.js",/' package.json
        update_docker_compose
        printf "\n${GREEN} ${microservice_name} was succesfully created!\n"
        ;;
    "${options[2]}")
        echo "Creating NodeJS (NestJS) microservice $microservice_name ..."
        move_to_microservice_folder
        # Initialize package.json and install dependencies
        npm init -y &&
        npm install --global @nestjs/cli &&
        nest new $microservice_name --skip-install &&
        cd $microservice_name &&
        npm install &&
        npm install --save-dev nodemon
        # Copying the template and creating the files
        dockerfile_content=$(cat ../../../../templates/infraestructure/docker/nodejs_dockerfile)
        # Creating the files
        echo "$dockerfile_content" > dockerfile
        # Add "start" script to package.json
        sed -i 's/"scripts": {/"scripts": {\n    "start": "nodemon src/main.ts",/' package.json
        update_docker_compose
        printf "\n${GREEN} ${microservice_name} was succesfully created!\n"
        ;;
    "${options[3]}")
        echo "Creating Rust (Actix) microservice $microservice_name ..."
        move_to_microservice_folder
        # Install Rust and create a new project
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        cargo new $microservice_name
        cd $microservice_name
        # Add Actix dependencies to Cargo.toml
        echo 'actix-web = "4"' >> Cargo.toml
        echo 'actix-rt = "2"' >> Cargo.toml
        echo 'serde = { version = "1", features = ["derive"] }' >> Cargo.toml
        # Replace src/main.rs with a basic Actix Web app
        echo 'use actix_web::{web, App, HttpResponse, HttpServer, Responder};' > src/main.rs
        echo 'use serde::Serialize;' >> src/main.rs
        # Build the project
        cargo build
        update_docker_compose
        printf "\n${GREEN} ${microservice_name} was succesfully created!\n"
        ;;
    "${options[4]}")
        echo "Exiting..."
        ;;
    *) echo "Invalid Option";;
esac

