#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
REGISTER_ENDPOINT="/users/register"
USER=${2:-"test0707"}
EMAIL=${3:-"test0707@example.com"}
PASSWORD=${4:-"password123"}

# Function to register a user
register_user() {
    response=$(curl -s -X POST "$API_URL$REGISTER_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$USER\", \"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}")

    echo $response
}

# Call the register_user function and print the response
register_user