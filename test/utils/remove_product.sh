#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_ENDPOINT="/products"
TOKEN=$2
PRODUCT_ID=$3

# Function to remove a product
remove_product() {
    response=$(curl -s -X DELETE "$API_URL$PRODUCTS_ENDPOINT/$PRODUCT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the remove_product function and print the response
remove_product