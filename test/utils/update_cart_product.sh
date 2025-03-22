#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
CART_ENDPOINT="/cart"
TOKEN=$2
PRODUCT_ID=$3
NEW_QUANTITY=$4

# Function to update product quantity in the cart
update_cart_product() {
    response=$(curl -s -X PUT "$API_URL$CART_ENDPOINT/$PRODUCT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
          \"quantity\": $NEW_QUANTITY
        }")

    echo $response
}

# Call the update_cart_product function and print the response
update_cart_product