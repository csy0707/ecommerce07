#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
LOGIN_ENDPOINT="/users/login"
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}

# Function to login as admin and get the token
admin_login() {
    response=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")

    token=$(echo $response | jq -r '.token')
    if [ "$token" == "null" ] || [ -z "$token" ]; then
        echo "❌ Login failed"
        exit 1
    fi

    echo $token
}

# Call the admin_login function and print the token
admin_login