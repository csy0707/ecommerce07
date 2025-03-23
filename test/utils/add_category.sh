#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CATEGORY_ENDPOINT="/categories"
TOKEN=$2
CATEGORY_NAME=${3:-"New Category"}

# Function to add a new category
add_category() {
    response=$(curl -s -X POST "$API_URL$CATEGORY_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{\"name\": \"$CATEGORY_NAME\"}")

    echo $response
}

# Call the add_category function and print the response
add_category