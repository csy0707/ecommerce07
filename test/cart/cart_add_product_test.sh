#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
USER_EMAIL=${2:-"test0707@example.com"}
USER_PASSWORD=${3:-"password123"}
QUANTITY=${4:-1}

# Main script
echo "🔹 Starting the add product to cart test script..."

# Call the standalone login script and capture the token
token=$(bash "$SCRIPT_DIR/../utils/login.sh" "$SERVER" "$USER_EMAIL" "$USER_PASSWORD")
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 User Token: $token"

# Call the standalone get products script and capture the response
products_response=$(bash "$SCRIPT_DIR/../utils/get_products.sh" "$SERVER" "$token")

# Debugging: Print the raw products response
echo "🔹 Raw Products Response: $products_response"

# Attempt to parse product IDs
product_ids=$(echo $products_response | jq -r '.[]._id' 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Failed to parse product IDs. Exiting."
    exit 1
fi

product_id_array=($product_ids)

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

# Call the standalone add to cart script and capture the response
ADD_TO_CART_RESPONSE=$(bash "$SCRIPT_DIR/../utils/add_to_cart.sh" "$SERVER" "$token" "$random_product_id" "$QUANTITY")

# Debugging: Print the add to cart response
echo "🔹 Add to Cart Response: $ADD_TO_CART_RESPONSE"

# Call the standalone view cart script and capture the response
cart_response=$(bash "$SCRIPT_DIR/../utils/view_cart.sh" "$SERVER" "$token")

# Debugging: Print the cart response
echo "🔹 Cart Response: $cart_response"

# Parse the cart response to extract product IDs and quantities
product_ids=$(echo $cart_response | jq -r '.items[].product._id')
quantities=$(echo $cart_response | jq -r '.items[].quantity')

# Print the parsed product IDs and quantities
echo "🔹 Products in Cart:"
for i in $(seq 0 $(($(echo "$product_ids" | wc -l) - 1))); do
    product_id=$(echo "$product_ids" | sed -n "$((i + 1))p")
    quantity=$(echo "$quantities" | sed -n "$((i + 1))p")
    echo "Product ID: $product_id, Quantity: $quantity"
done

echo "🔹 Finished the add product to cart test script."

