require 'page-object'
require_relative './search_results_page.rb'

module Etsy
  class HomePage
    include PageObject

    page_url "http://www.etsy.com"

    text_field(:query, name: 'search_query')
    button(:search!, name: 'search_submit')

    def search_for(query)
      self.query = query
      search!
      return Etsy::SearchResultsPage.new(browser)
    end
  end
end