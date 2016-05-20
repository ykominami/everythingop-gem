class CreateInvalidcategory < ActiveRecord::Migration
  def self.up
    create_table :invalidcategories do |t|
      t.column :org_id, :int, :null => false
      t.column :count_id, :int, :null => true
    end
  end

  def self.down
    drop_table :invalidcategories
  end
end
