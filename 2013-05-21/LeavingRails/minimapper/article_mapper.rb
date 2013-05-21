require 'minimapper/mapper/ar'

class ArticleMapper < Minimapper::Mapper::AR
  def published
    entities_for(record_class.where(published: true))
  end
end