require 'curator'

class PlayerRepository
  include Curator::Repository

  indexed_fields :name
end