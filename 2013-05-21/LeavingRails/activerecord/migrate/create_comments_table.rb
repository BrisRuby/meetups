require 'active_record'

class CreateCommentsTable < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :article_id
      t.string :email
      t.string :text
      t.boolean :moderated
    end
  end
end