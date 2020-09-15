require 'json'
require 'date'

DATA = JSON.parse(File.read('./data/input.json'))
CARRIERS = DATA['carriers']
PACKAGES = DATA['packages']

def saturday_delay(carrier_code)
  CARRIERS.find { |c| c['code'] == carrier_code }['saturday_deliveries'] ? 0 : 1
end

def weekday(date_string)
  Date.parse(date_string).strftime("%A")
end

def number_of_a_certain_weekday_between(target_day, start_date, end_date)
  ((start_date..end_date).to_a.select { |k| [target_day].include?(k.wday) }).length
end

def get_expected_delivery_date(package)
  id = package['id']
  carrier = PACKAGES.find { |p| p['id'] == id }['carrier']
  delay = CARRIERS.find { |c| c['code'] == carrier}['delivery_promise']
  shipping_date = DateTime.parse(PACKAGES.find { |p| p['id'] == id }['shipping_date'])
  delivery_date = shipping_date + 1 + delay
  delivery_date + number_of_a_certain_weekday_between(0, shipping_date, delivery_date) + number_of_a_certain_weekday_between(6, shipping_date, delivery_date) * saturday_delay(carrier)
end

def perform
  list = PACKAGES.map { |p| { "package_id": p['id'], "expected_delivery": get_expected_delivery_date(p).strftime('%F') }}
  result = { "deliveries": list }
  file = File.new('./output.json', 'w')
  file.write(result.to_json)
end

perform
