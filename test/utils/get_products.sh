#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_ENDPOINT="/products"
TOKEN=$2

# Function to get all products
get_products() {
    response=$(curl -s -X GET "$API_URL$PRODUCTS_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the get_products function and print the response
get_products