#!/bin/bash

echo "This script can remove the following folders and containers:"

COLUMNS=12
PS3='Input your choice : '
options=(
    "Stop every containers (but don't remove them)"
    "Stop and remove every containers (keep persistent volumes)"
    "Database (./data/)" 
    "Recordings (./record/)"
    "Drive files (./drive/)"
    "Every folders (./data/, ./drive/, ./record/)"
    "Everything, except windows persistent volume"
    "Everything (do all the above, reset everything)"
    "Exit"
)

select opt in "${options[@]}"
do
    case $opt in
        "Stop every containers (but don't remove them)")
            echo "Stopped :"
            docker stop ${WINDOWS_CONTAINER_NAME} ${DEBIAN_CONTAINER_NAME} ${POSTGRES_CONTAINER_NAME} ${GUACD_CONTAINER_NAME} ${GUACAMOLE_CONTAINER_NAME} ${NGINX_CONTAINER_NAME}
            echo "Done!"
            ;;
        "Stop and remove every containers (keep persistent volumes)")
            echo "Stopped and removed :"
            docker compose down
            echo "Done!"
            ;;
        "Database (./data/)")
            rm -r -f ./data/
            echo "Done!"
            ;;
        "Recordings (./record/)")
            rm -r -f ./record/
            echo "Done!"
            ;;
        "Drive files (./drive/)")
            rm -r -f ./drive/
            echo "Done!"
            ;;
        "Every folders (./data/, ./drive/, ./record/)")
            rm -r -f ./data/ ./drive/ ./record/
            echo "Done!"
            ;;
        "Everything, except windows persistent volume")
            echo "Stopped and removed :"
            docker compose down
            rm -r -f ./data/ ./drive/ ./record/
            docker network prune -f
            echo "Done!"
            ;;
        "Everything (do all the above, reset everything)")
            echo "Stopped and removed :"
            docker compose down
            rm -r -f ./data/ ./drive/ ./record/ ./windata/
            docker network prune -f
            echo "Done!"
            ;;
        "Exit")
            exit
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done
