#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_ENDPOINT="/products"
TOKEN=$2
PRODUCT_ID=$3
UPDATED_PRODUCT_NAME=${4:-"Updated Product"}
UPDATED_PRODUCT_PRICE=${5:-99.99}
UPDATED_PRODUCT_DESCRIPTION=${6:-"Updated description"}

# Function to update the product
update_product() {
    response=$(curl -s -X PUT "$API_URL$PRODUCTS_ENDPOINT/$PRODUCT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
            \"name\": \"$UPDATED_PRODUCT_NAME\",
            \"price\": $UPDATED_PRODUCT_PRICE,
            \"description\": \"$UPDATED_PRODUCT_DESCRIPTION\"
        }")

    echo $response
}

# Call the update_product function and print the response
update_product