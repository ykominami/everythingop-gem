$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'everythingop'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Everythingop
  TEST_DATA_DIR = Pathname.new(__dir__).join('test_data')
end

def test_file_base_pn
  if ENV['TEST_DATA_DIR']
    Pathname.new(ENV['TEST_DATA_DIR'])
  else
    Everythingop::TEST_DATA_DIR
  end
end

def test_setup
  # puts "TEST_DATA_DIR=#{Flist::TEST_DATA_DIR}"
  _home_dir = Everythingop::TEST_DATA_DIR.join('home')
  data_dir = Everythingop::TEST_DATA_DIR.join('data')
  infile = data_dir.join('20221004.yml')
  # content = File.read(config_yml)
  scope = Object.new
  value_hash = {}
  # value_hash = { test_data_dir: Everythingop::TEST_DATA_DIR.to_s }
  in_content = Ykutils::Erubyx.erubi_render_with_template_file(infile, scope, value_hash)
  Ykxutils.yaml_load_compati(in_content)
end

def everythingop_setup(hash)
  Everythingop::Everythingop.new(
    hash, hash['group_fname'], hash['infname']
  )
end
