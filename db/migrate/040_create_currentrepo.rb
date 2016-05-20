class CreateCurrentrepo < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE VIEW currentrepos AS SELECT id as org_id,
category_id , desc , path , mtime , ctime    
      FROM repos where not exists (select * from invalidrepos where invalidrepos.org_id = repos.id )
    SQL
  end

  def self.down
    execute <<-SQL
      DROP VIEW currentrepos
    SQL
  end
end
