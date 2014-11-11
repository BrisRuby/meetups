db = 'mm.sqlite3'
File.delete(db) if File.exists?(db)

require 'connect'
require 'migrate'

require 'article'
require 'article_mapper'

[CreateArticlesTable, CreateCommentsTable].map { |m| m.new.migrate :change }

#article = Article.new title: 'Hello World', slug: 'hello_world', body: 'lorem ipsum'
#article_mapper = ArticleMapper.new
#article_mapper.create(article)

#article = article_mapper.find(article.id)

#article.published = true
#article_mapper.update(article)

#article_mapper.delete(article)
