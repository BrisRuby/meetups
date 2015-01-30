require 'selenium-webdriver'
require_relative './etsy/home_page.rb'
require_relative './etsy/search_results_page.rb'
require_relative './etsy/listing_page.rb'

driver = Selenium::WebDriver.for :firefox
search_page = Etsy::HomePage.new(driver, true)

results_page = search_page.search_for('vintage')
results_page.first

listing_page = Etsy::ListingPage.new(driver)
puts listing_page.title
puts listing_page.overview

driver.quit
