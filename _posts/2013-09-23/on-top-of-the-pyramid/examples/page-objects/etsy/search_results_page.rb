require 'page-object'

module Etsy
  class SearchResultsPage
  	include PageObject

  	link(:first, class: 'listing-thumb')
  end
end