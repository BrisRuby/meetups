class Comment
  include Minimapper::Entity

  belongs_to :article

  attr_accessible :email, :text

  validates_presence_of :email, :text
end