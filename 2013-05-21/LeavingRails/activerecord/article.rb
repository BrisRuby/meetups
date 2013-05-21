require 'active_record'

class Article < ActiveRecord::Base
  has_many :comments

  validates_presence_of :title, :slug

  validates_uniqueness_of :slug

  scope :published, where(published: true)

  def publish!
    self.published = true
    self.save
  end
end
