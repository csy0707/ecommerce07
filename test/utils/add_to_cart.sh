#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CART_ENDPOINT="/cart"
TOKEN=$2
PRODUCT_ID=$3
QUANTITY=${4:-1}

# Function to add a product to the cart
add_to_cart() {
    response=$(curl -s -X POST "$API_URL$CART_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
          \"productId\": \"$PRODUCT_ID\",
          \"quantity\": $QUANTITY
        }")

    echo $response
}

# Call the add_to_cart function and print the response
add_to_cart