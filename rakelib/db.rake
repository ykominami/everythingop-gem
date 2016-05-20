# coding: utf-8
require 'arxutils'

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
      :plural => "repos"
    },

    {
      :flist => %W!base invalid current!,
      :classname => "Category",
      :classname_downcase => "category",

      :items => [
        ["name" , "string", "false"],
        ["parent_id" , "int", "false"],
        ["path" , "string", "false"],
      ],
      :plural => "categories"
    },
    
  ]

  dbconfig = Arxutils::Dbutil::DBCONFIG_MYSQL
  dbconfig = Arxutils::Dbutil::DBCONFIG_SQLITE3

  forced = true
  Arxutils::Migrate.migrate(
    db_def_ary,
    0,
    dbconfig,
    forced
  )

end
