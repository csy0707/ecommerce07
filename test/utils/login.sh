#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
LOGIN_ENDPOINT="/users/login"
USER_EMAIL=${2:-"test0707@example.com"}
USER_PASSWORD=${3:-"password123"}

# Function to login and get the token
login() {
    response=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$USER_EMAIL\", \"password\": \"$USER_PASSWORD\"}")

    token=$(echo $response | jq -r '.token')
    if [ "$token" == "null" ] || [ -z "$token" ]; then
        echo "❌ Login failed"
        exit 1
    fi

    echo $token
}

# Call the login function and print the token
login