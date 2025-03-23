#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CATEGORY_ENDPOINT="/categories"
TOKEN=$2
CATEGORY_ID=$3

# Function to remove a category
remove_category() {
    response=$(curl -s -X DELETE "$API_URL$CATEGORY_ENDPOINT/$CATEGORY_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the remove_category function and print the response
remove_category