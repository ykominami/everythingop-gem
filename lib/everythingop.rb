require 'arxutils_sqlite3'
require_relative 'dbacrecord'
require_relative 'everythingop/version'
require_relative 'everythingop/everythingop'
require_relative 'everythingop/dbutil'
require_relative 'everythingop/cli'

# Everything用操作モジュール
module Everythingop
  OUTPUT_DIR = 'output'.freeze
  # PSTORE_DIR = "pstore"
  PSTORE_DIR = 'pstore'.freeze
  PSTORE_KEY = :TOP
end
