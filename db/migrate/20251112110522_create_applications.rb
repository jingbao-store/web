class CreateApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :applications do |t|
      t.string :name, null: false
      t.string :package_name, null: false
      t.string :version
      t.text :description
      t.string :icon
      t.string :download_url
      t.string :file_size
      t.bigint :file_size_bytes
      t.string :developer
      t.decimal :rating, precision: 3, scale: 2
      t.integer :downloads, default: 0, null: false
      t.date :last_updated
      t.string :min_android_version
      t.text :permissions
      t.text :features
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :applications, :package_name, unique: true
    add_index :applications, :downloads
    add_index :applications, :rating
  end
end
