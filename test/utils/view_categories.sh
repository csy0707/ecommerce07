#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CATEGORY_ENDPOINT="/categories"
TOKEN=$2

# Function to view all categories
view_categories() {
    response=$(curl -s -X GET "$API_URL$CATEGORY_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the view_categories function and print the response
view_categories