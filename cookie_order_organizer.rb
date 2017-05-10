require 'net/http'
require 'json'


# computes the total number of cookies in an order
def sum_cookies(order)
  order["products"].map{ |product| product["title"] == "Cookie" ? product["amount"] : 0}.inject(:+)
end

remaining_cookies = 0   # assuming remaining cookies in one page cannot be used for another page
unfulfilled_orders = []

for page in 1..11
  # make api request and get the response
  url = "https://backend-challenge-fall-2017.herokuapp.com/orders.json?page=#{page}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  response = JSON.parse(response)

  available_cookies = response["available_cookies"]
  orders = response["orders"]

  prioritized_orders = orders.map{ |order| {id: order["id"], cookie_amount: sum_cookies(order)}}. # computes total amount of cookies
      select{ |order| order[:cookie_amount] > 0}.  # filter orders that do not contain cookies
      sort_by{ |order| [-order[:cookie_amount], order[:id]] }  # prioritize orders, by cookie_amount desc, order_id asc

  # debugging printings
  puts "page=#{page}"
  puts prioritized_orders

  # computes remaining cookies for each page
  for order in prioritized_orders
    if order[:cookie_amount] > available_cookies
      unfulfilled_orders.push(order[:id])  # record unfulfilled orders
    else
      available_cookies -= order[:cookie_amount]
    end
  end

  remaining_cookies += available_cookies
end

result = { remaining_cookies: remaining_cookies, unfulfilled_orders: unfulfilled_orders.sort }
json_result = result.to_json

puts json_result






