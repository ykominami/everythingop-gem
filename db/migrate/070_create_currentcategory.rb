class CreateCurrentcategory < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE VIEW currentcategories AS SELECT id as org_id,
name , parent_id , path    
      FROM categories where not exists (select * from invalidcategories where invalidcategories.org_id = categories.id )
    SQL
  end

  def self.down
    execute <<-SQL
      DROP VIEW currentcategories
    SQL
  end
end
