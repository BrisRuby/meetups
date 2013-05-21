class CreateTwats < ActiveRecord::Migration
  def change
    create_table :twats do |t|
      t.string :author
      t.text :status

      t.timestamps
    end
  end
end
