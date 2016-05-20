class CreateCount < ActiveRecord::Migration
  def self.up
    create_table :counts do |t|
    
      t.column :countdatetime, :datetime, :null => false
    
    end
  end

  def self.down
    drop_table :counts
  end
end
