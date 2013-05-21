require 'connect'
require 'migrate'
require 'article.rb'
require 'comment.rb'

db = 'ar.sqlite3'
File.delete(db) if File.exists?(db)

[CreateArticlesTable, CreateCommentsTable].map { |m| m.new.migrate :change }

article = Article.create title: 'Hello World', slug: 'hello_world', body: 'lorem ipsum', published: true
article.comments.create email: 'someone@example.com', text: 'woo!'
article.comments.create email: 'everyone@example.com', text: 'oh yeah!', moderated: true

Article.create title: '[Draft] Something Interesting', slug: 'hmm', body: 'Pending'

p Article.find(article.id)
p Article.find(article.id).comments.moderated
