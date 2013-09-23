require 'page-object'

module Etsy
  class ListingPage
  	include PageObject

  	div(:right_column, id: 'listing-right-column')
  	h1(:title) { |page| page.right_column_element.h1_element }
  	div(:overview, id: 'item-overview')
  end
end