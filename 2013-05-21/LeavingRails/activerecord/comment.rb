require 'active_record'

class Comment < ActiveRecord::Base
  belongs_to :article

  validates_presence_of :email, :text

  scope :moderated, where(moderated: true)
end