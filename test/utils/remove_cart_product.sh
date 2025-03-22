#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CART_ENDPOINT="/cart"
TOKEN=$2
PRODUCT_ID=$3

# Function to remove a product from the cart
remove_cart_product() {
    response=$(curl -s -X DELETE "$API_URL$CART_ENDPOINT/$PRODUCT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

    echo $response
}

# Call the remove_cart_product function and print the response
remove_cart_product