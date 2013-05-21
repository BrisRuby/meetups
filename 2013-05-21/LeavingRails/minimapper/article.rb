require 'active_record'
require 'minimapper/entity'

class Article < ActiveRecord::Base
  include ::Minimapper::Entity::Core

  attr_accessible :title, :slug, :body, :published

  validates_presence_of :title, :slug, :body

  validates_uniqueness_of :slug
end