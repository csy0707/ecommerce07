#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CART_ENDPOINT="/cart"
TOKEN=$2

# Function to view cart
view_cart() {
    response=$(curl -s -X GET "$API_URL$CART_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the view_cart function and print the response
view_cart