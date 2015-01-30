require 'minimapper/repository'

repository = Minimapper::Repository.build(articles: ArticleMapper.new)