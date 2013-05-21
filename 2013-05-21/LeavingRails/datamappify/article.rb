require 'datamappify'

class Article
  include Datamappify::Entity

  attribute :title, String
  attribute :slug, String
  attribute :body, String
  attribute :published, Boolean, default: false

  validates_presence_of :title, :slug, :body
end