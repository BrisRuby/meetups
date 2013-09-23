require 'watir-webdriver'

browser = Watir::Browser.new

browser.goto 'bit.ly/watir-webdriver-demo'

browser.text_field(:id => 'entry_0').set 'your name'
browser.select_list(:id => 'entry_1').select 'Ruby'
browser.select_list(:id => 'entry_1').selected? 'Ruby'
browser.button(:name => 'submit').click

puts 'winning!' if browser.text.include? 'Thank you'
browser.close