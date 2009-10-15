class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :crypted_password
      t.string  :password_salt
      t.string  :persistence_token 
      t.boolean :active, :default => true, :null => false
      t.timestamps
    end

    add_index :users, :active
  end

  def self.down
    drop_table :users
  end
end
