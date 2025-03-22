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

# Parse product IDs from the cart response
cart_product_ids=$(echo $cart_response | jq -r '.items[].product._id' 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Failed to parse cart product IDs. Exiting."
    exit 1
fi

cart_product_id_array=($cart_product_ids)

# Check if there are no products in the cart
if [ ${#cart_product_id_array[@]} -eq 0 ]; then
    echo "❌ No products in the cart. Exiting."
    exit 1
fi

random_cart_product_id=${cart_product_id_array[$RANDOM % ${#cart_product_id_array[@]}]}

# Update the quantity of a random product in the cart
new_quantity=$((QUANTITY + 1))
echo "🔹 Updating the quantity of a random product in the cart..."
UPDATE_CART_RESPONSE=$(bash "$SCRIPT_DIR/../utils/update_cart_product.sh" "$SERVER" "$token" "$random_cart_product_id" "$new_quantity")

# Debugging: Print the update cart response
echo "🔹 Update Cart Response: $UPDATE_CART_RESPONSE"

echo "🔹 Finished the add product to cart test script."

