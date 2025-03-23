#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_ENDPOINT="/products"
TOKEN=$2
PRODUCT_ID=$3
UPDATED_CATEGORY_ID=${4:-"new_category_id"}

# Function to update the product category
update_product_category() {
    response=$(curl -s -X PUT "$API_URL$PRODUCTS_ENDPOINT/$PRODUCT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
            \"category\": \"$UPDATED_CATEGORY_ID\"
        }")

    echo $response
}

# Call the update_product_category function and print the response
update_product_category