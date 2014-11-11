require 'tire'
require 'tire/model/dynamic_persistence'

class Twat 
  include Tire::Model::Persistence
  include Tire::Model::DynamicPersistence
end
