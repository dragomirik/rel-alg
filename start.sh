#!/bin/bash

# Stop any existing containers and remove them
docker-compose down

# Build and start the service
docker-compose up --build
