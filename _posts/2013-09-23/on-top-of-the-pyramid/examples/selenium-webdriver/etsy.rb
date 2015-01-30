require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox
driver.get "http://www.etsy.com"

search_bar = driver.find_element(name: 'search_query')

wait = Selenium::WebDriver::Wait.new(:timeout => 10)
wait.until { search_bar.displayed? }

search_bar.send_keys('vintage')

autocomplete = driver.find_element(id: 'search-suggestions')
suggestions = autocomplete.find_elements(class: 'as-suggestion')
puts "Found #{suggestions.count} suggestions"

suggestions[rand(suggestions.count)].click

listings = driver.find_elements(class: 'listings').map { |e|
  e.find_elements(tag_name: 'li')
}.flatten

puts "Found #{listings.count} listings"

listing = listings[rand(listings.count)]

puts listing.find_element(class: 'listing-title').text
listing.find_element(tag_name: 'a').click

overview = driver.find_element(id: 'item-overview')

puts overview.text

driver.quit
