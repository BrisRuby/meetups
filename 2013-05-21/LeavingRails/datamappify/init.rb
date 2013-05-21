require 'connect'
require 'migrations'
require 'article'
require 'article_repository'

db = 'dm.sqlite3'
File.delete(db) if File.exists?(db)

[CreateArticlesTable, CreateCommentsTable].map { |m| m.new.migrate :change }

article = Article.new title: 'Hello World', slug: 'hello_world', body: 'lorem ipsum'
ArticleRepository.save(article)

article = ArticleRepository.find(article.id)

article.published = true
ArticleRepository.save(article)

ArticleRepository.destroy(article)
