require 'json'
require 'date'

DATA = JSON.parse(File.read('./data/input.json'))
CARRIER = DATA['carriers']
PACKAGES = DATA['packages']

def get_expected_delivery_date(package)
  id = package['id']
  carrier = PACKAGES.find { |p| p['id'] == id }['carrier']
  delay = CARRIER.find { |c| c['code'] == carrier }['delivery_promise']
  shipping_date = PACKAGES.find { |p| p['id'] == id }['shipping_date']
  delivery_date_with_margin = (DateTime.parse(shipping_date) + delay + 1).strftime('%F')
  delivery_date_with_margin
end

def perform
  list = PACKAGES.map { |p| { "package_id": p['id'], "expected_delivery": get_expected_delivery_date(p) } }
  result = { "deliveries": list }
  file = File.new('./output.json', 'w')
  file.write(result.to_json)
end

perform
