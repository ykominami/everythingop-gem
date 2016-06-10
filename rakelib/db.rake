# coding: utf-8
require 'arxutils'
require 'yaml'

desc <<-EOS
  db migration
EOS
task :migrate do
  db_def_ary = [
    {
      :flist => %W!noitem!,
      :classname => "Count",
      :classname_downcase => "count",
      :items => [
        ["countdatetime" , "datetime", "false"],
      ],
      :plural => "counts"
    },

    {
      :flist => %W!base invalid current!,
      :classname => "Repo",
      :classname_downcase => "repo",

      :items => [
        ["category_id" , "integer", "false"],
        ["desc" , "string", "true"],
        ["path" , "string", "false"],
        ["mtime" , "int", "false"],
        ["ctime" , "int", "false"],
      ],
      :plural => "repos",
      :relation => [
        %Q!belongs_to :category , foreign_key: 'category_id'!,
      ],
    },

    {
      :flist => %W!base invalid current!,
      :classname => "Category",
      :classname_downcase => "category",

      :items => [
        ["name" , "string", "false"],
        ["path" , "string", "false"],
        ["hier" , "string", "false"],
      ],
      :plural => "categories",
      :relation => [
        %Q!has_many :repos!,
      ]
    },

    {
      :flist => %W!noitem!,
      :classname => "Categoryhier",
      :classname_downcase => "categoryhier",

      :items => [
        ["parent_id" , "int", "false"],
        ["child_id" , "int", "true"],
        ["level" , "int", "false"],
      ],
      :plural => "categoryhiers",
      :relation => [
        %Q!belongs_to :category , foreign_key: 'parent_id'!,
        %Q!belongs_to :category , foreign_key: 'child_id'!,
      ],
    },
    
    {
      :flist => %W!noitem!,
      :classname => "Management",
      :classname_downcase => "management",

      :items => [

        ["ctime" , "int", "false"],
        ["mtime" , "int", "false"],
      ],
      :plural => "managements",
    },

    {
      :flist => %W!noitem!,
      :classname => "Criteria",
      :classname_downcase => "criteria",

      :items => [

        ["level" , "int",    "true"],
        ["key"   , "string", "false"],
        ["value" , "string", "false"],
      ],
      :plural => "criteria",
    },
  ]

  dbconfig = Arxutils::Dbutil::DBCONFIG_MYSQL
  dbconfig = Arxutils::Dbutil::DBCONFIG_SQLITE3
  forced = true
  Arxutils::Migrate.migrate(
    db_def_ary,
    %q!lib/everythingop/relation.rb!,
    "Everythingop",
    "count",
    "end_count_id",
    dbconfig,
    forced
  )

end
