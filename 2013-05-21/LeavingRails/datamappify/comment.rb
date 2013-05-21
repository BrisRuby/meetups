require 'datamappify'

class Comment
  include Datamappify::Entity

  attribute :email, String
  attribute :text, String

  validates_presence_of :email, :text
end