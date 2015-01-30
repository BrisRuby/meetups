require 'active_record'

class CreateArticlesTable < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.boolean :published
    end
  end
end