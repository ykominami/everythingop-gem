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
        ["hier1item_id" , "integer", "true"],
        ["hier2item_id" , "integer", "true"],
        ["hier3item_id" , "integer", "true"],
      ],
      :plural => "repos",
      :relation => [
        %Q!belongs_to :category , foreign_key: 'category_id'!,
        %Q!belongs_to :hier1item , foreign_key: 'hier1item_id'!,
        %Q!belongs_to :hier2item , foreign_key: 'hier2item_id'!,
        %Q!belongs_to :hier3item , foreign_key: 'hier3item_id'!,
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
        %Q!belongs_to :parent , class_name: 'Category' , foreign_key: 'parent_id'!,
        %Q!belongs_to :child  , class_name: 'Category' , foreign_key: 'child_id'!,
      ],
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

    {
      :flist => %W!base invalid current!,
      :classname => "Hier1item",
      :classname_downcase => "hier1item",

      :items => [
        ["hier" , "string", "false"],
      ],
      :plural => "hier1items",
      :relation => [
        %Q!has_many :repos!,
      ]
    },

    {
      :flist => %W!base invalid current!,
      :classname => "Hier2item",
      :classname_downcase => "hier2item",

      :items => [
        ["hier" , "string", "false"],
      ],
      :plural => "hier2items",
      :relation => [
        %Q!has_many :repos!,
      ]
    },

    {
      :flist => %W!base invalid current!,
      :classname => "Hier3item",
      :classname_downcase => "hier3item",

      :items => [
        ["hier" , "string", "false"],
      ],
      :plural => "hier3items",
      :relation => [
        %Q!has_many :repos!,
      ]
    },

    {
      :flist => %W!noitem!,
      :classname => "Hier1",
      :classname_downcase => "hier1",

      :items => [
        ["parent_id" , "int", "false"],
        ["child_id"  , "int", "false"],
        ["level"     , "int", "false"],
      ],
      :plural => "hier1s",
      :relation => [
        %Q!belongs_to :parent , class_name: 'Hier1item' , foreign_key: 'parent_id'!,
        %Q!belongs_to :child  , class_name: 'Hier1item' , foreign_key: 'child_id'!,
      ],
    },

    {
      :flist => %W!noitem!,
      :classname => "Hier2",
      :classname_downcase => "hier2",

      :items => [
        ["parent_id" , "int", "false"],
        ["child_id"  , "int", "false"],
        ["level"     , "int", "false"],
      ],
      :plural => "hier2s",
      :relation => [
        %Q!belongs_to :parent , class_name: 'Hier2item' , foreign_key: 'parent_id'!,
        %Q!belongs_to :child  , class_name: 'Hier2item' , foreign_key: 'child_id'!,
      ],
    },

    {
      :flist => %W!noitem!,
      :classname => "Hier3",
      :classname_downcase => "hier3",

      :items => [
        ["parent_id" , "int", "false"],
        ["child_id"  , "int", "false"],
        ["level"     , "int", "false"],
      ],
      :plural => "hier3s",
      :relation => [
        %Q!belongs_to :parent , class_name: 'Hier3item' , foreign_key: 'parent_id'!,
        %Q!belongs_to :child  , class_name: 'Hier3item' , foreign_key: 'child_id'!,
      ],
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
