require 'json'
require 'date'

DATA = JSON.parse(File.read('./data/input.json'))
CARRIERS = DATA['carriers']
PACKAGES = DATA['packages']
DISTANCES = DATA['country_distance']

def saturday_delay_index(carrier_code)
  CARRIERS.find { |c| c['code'] == carrier_code }['saturday_deliveries'] ? 0 : 1
end

def number_of_a_certain_weekday_between(target_day, start_date, end_date)
  ((start_date..end_date).to_a.select { |k| [target_day].include?(k.wday) }).length
end

def package_international_distance(package_id)
  package = PACKAGES.find { |p| p['id'] == package_id }
  origin_country = package['origin_country']
  destination_country = package['destination_country']
  origin_country == destination_country ? 0 : DISTANCES[origin_country][destination_country]
end

def weekend_delay(shipping_date, theoritical_delivery_date, carrier_code)
  sunday_delay = number_of_a_certain_weekday_between(0, shipping_date, theoritical_delivery_date)
  saturday_delay = saturday_delay_index(carrier_code) * number_of_a_certain_weekday_between(6, shipping_date, theoritical_delivery_date)
  saturday_delay + sunday_delay
end

def international_delay(distance, carrier)
  distance / carrier['oversea_delay_threshold']
end

def get_expected_delivery_date_and_oversea_delay(package)
  id = package['id']
  distance = package_international_distance(id)
  carrier_code = PACKAGES.find { |p| p['id'] == id }['carrier']
  carrier = CARRIERS.find { |c| c['code'] == carrier_code }
  delay = CARRIERS.find { |c| c['code'] == carrier_code}['delivery_promise']
  shipping_date = DateTime.parse(PACKAGES.find { |p| p['id'] == id }['shipping_date'])
  theoritical_delivery_date = shipping_date + 1 + delay
  oversea_delay = international_delay(distance, carrier)
  delivery_date = theoritical_delivery_date + weekend_delay(shipping_date, theoritical_delivery_date, carrier_code) + oversea_delay
  {
    "package_id": id,
    "expected_delivery": delivery_date.strftime('%F'),
    "oversea_delay": oversea_delay
  }
end

def perform
  list = PACKAGES.map { |p| get_expected_delivery_date_and_oversea_delay(p) }
  result = { "deliveries": list }
  file = File.new('./output.json', 'w')
  file.write(result.to_json)
end

perform
