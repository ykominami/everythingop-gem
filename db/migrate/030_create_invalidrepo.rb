class CreateInvalidrepo < ActiveRecord::Migration
  def self.up
    create_table :invalidrepos do |t|
      t.column :org_id, :int, :null => false
      t.column :count_id, :int, :null => true
    end
  end

  def self.down
    drop_table :invalidrepos
  end
end
