require 'datamappify'
require 'forwardable'

class ArticleRepository
  include Datamappify::Repository

  for_entity Article

  default_provider :ActiveRecord
end