#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
USER_EMAIL=${2:-"test0707@example.com"}
USER_PASSWORD=${3:-"password123"}
QUANTITY=${4:-1}

# Function to count the number of products in the cart
count_cart_products() {
    cart_response=$1
    product_count=$(echo $cart_response | jq '.items | length')
    echo $product_count
}

# Function to count the quantity of each product in the cart
count_product_quantities() {
    cart_response=$1
    product_quantities=$(echo $cart_response | jq -r '.items[] | "\(.product._id): \(.quantity)"')
    echo "$product_quantities"
}

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

# Add a random product to the cart
API_URL="http://$SERVER/api"
CART_ENDPOINT="/cart"
echo "🔹 Adding a random product to the cart..."
ADD_TO_CART_RESPONSE=$(curl -s -X POST "$API_URL$CART_ENDPOINT" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $token" \
-d "{
  \"productId\": \"$random_product_id\",
  \"quantity\": $QUANTITY
}")

# Debugging: Print the add to cart response
echo "🔹 Add to Cart Response: $ADD_TO_CART_RESPONSE"

# Call the standalone view cart script and capture the response
cart_response=$(bash "$SCRIPT_DIR/../utils/view_cart.sh" "$SERVER" "$token")

# Debugging: Print the cart response
echo "🔹 Cart Response: $cart_response"

# Count the number of products in the cart
product_count=$(count_cart_products "$cart_response")
echo "🔹 Number of products in the cart: $product_count"

# Count the quantity of each product in the cart
echo "🔹 Quantities of each product in the cart:"
count_product_quantities "$cart_response"

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

# Call the standalone remove cart product script and capture the response
REMOVE_CART_RESPONSE=$(bash "$SCRIPT_DIR/../utils/remove_cart_product.sh" "$SERVER" "$token" "$random_cart_product_id")

# Debugging: Print the remove cart response
echo "🔹 Remove Cart Response: $REMOVE_CART_RESPONSE"

# Call the standalone view cart script again and capture the response
cart_response=$(bash "$SCRIPT_DIR/../utils/view_cart.sh" "$SERVER" "$token")

# Debugging: Print the cart response after removal
echo "🔹 Cart Response after removal: $cart_response"

# Count the number of products in the cart after removal
product_count=$(count_cart_products "$cart_response")
echo "🔹 Number of products in the cart after removal: $product_count"

# Count the quantity of each product in the cart after removal
echo "🔹 Quantities of each product in the cart after removal:"
count_product_quantities "$cart_response"

echo "🔹 Finished the add product to cart test script."

