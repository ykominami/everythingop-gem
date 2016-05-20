class CreateCategory < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
    
      t.column :name, :string, :null => false
    
      t.column :parent_id, :int, :null => false
    
      t.column :path, :string, :null => false
    
    end
  end

  def self.down
    drop_table :categories
  end
end
