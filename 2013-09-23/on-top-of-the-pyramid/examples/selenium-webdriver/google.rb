require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox
driver.get "http://google.com"

element = driver.find_element :name => "q"
element.send_keys "Cheese!"
element.submit

wait = Selenium::WebDriver::Wait.new(:timeout => 10)
wait.until { driver.find_element(id: 'resultStats').displayed? }

puts driver.find_element(id: 'resultStats').text

driver.quit
