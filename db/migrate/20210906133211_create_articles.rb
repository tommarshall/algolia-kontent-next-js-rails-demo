class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.string :tags
      t.string :author
      t.datetime :published_at
      t.string :image
      t.integer :estimated_reading_time_mins
      t.string :url_slug
      t.string :kentico_id
      t.boolean :published

      t.timestamps
    end
  end
end
