class CreateRepo < ActiveRecord::Migration
  def self.up
    create_table :repos do |t|
    
      t.column :category_id, :integer, :null => false
    
      t.column :desc, :string, :null => true
    
      t.column :path, :string, :null => false
    
      t.column :mtime, :int, :null => false
    
      t.column :ctime, :int, :null => false
    
    end
  end

  def self.down
    drop_table :repos
  end
end
