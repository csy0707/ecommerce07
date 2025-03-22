#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
LOGOUT_ENDPOINT="/users/logout"
TOKEN=$2

# Function to logout a user
logout_user() {
    response=$(curl -s -X POST "$API_URL$LOGOUT_ENDPOINT" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the logout_user function and print the response
logout_user