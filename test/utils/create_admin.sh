#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
REGISTER_ADMIN_ENDPOINT="/users/register/admin"
ADMIN_TOKEN=$2
NEW_ADMIN_USERNAME=${3:-"newadmin"}
NEW_ADMIN_EMAIL=${4:-"newadmin@example.com"}
NEW_ADMIN_PASSWORD=${5:-"newadmin123"}
NEW_ADMIN_ROLE=${6:-"admin"}

# Function to create a new admin user
create_admin() {
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL$REGISTER_ADMIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -d "{
            \"username\": \"$NEW_ADMIN_USERNAME\",
            \"email\": \"$NEW_ADMIN_EMAIL\",
            \"password\": \"$NEW_ADMIN_PASSWORD\",
            \"role\": \"$NEW_ADMIN_ROLE\"
        }")

    # Extract the HTTP status code from the response
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    # Print the response
    echo "$http_code"
    echo "$response_body"
}

# Call the create_admin function
create_admin