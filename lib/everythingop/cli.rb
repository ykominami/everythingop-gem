require 'simpleoptparse'

module Everythingop
  # Everything用操作クラス
  class Cli
    include Ykutils::DebugUtils

    # 初期化
    def initialize(argv)
      puts "argv=#{argv}"
      banner = 'Usage: bundle exec ruby exe/flist --cmd=[s|f] --group group_yaml --infile infile_yaml --verbose'

      opts = {}
      opts['verbose'] = false
      begin
        Simpleoptparse::Simpleoptparse.parse(argv, opts, banner, ::Everythingop::VERSION, nil) do |parser|
          parser.on('--cmd=X', %w[s f]) { |x| opts['cmd'] = x }
          parser.on('--group=group_yaml') { |x| opts['group'] = x }
          parser.on('--infile=infile_yaml') { |x| opts['infile'] = x }
          parser.on('--verbose') { |_x| opts['verbose'] = true }
        end
      rescue OptionParser::InvalidArgument => e
        puts e.message
        puts banner
        exit Flist::EXIT_CODE_INVALID_CODE
      end
      @cmd = opts['cmd']
      @infile = opts['infile']
      @group_file = opts['group']

      debug_utils_init
      set_debug(opts['verbose'])
    end

    # 構成情報設定
    def setup
      env = ENV.fetch('ENV', 'production')

      {
        'db_dir' => Arxutils_Sqlite3::Config::DB_DIR,
        'migrate_dir' => Arxutils_Sqlite3::Config::MIGRATE_DIR,
        'config_dir' => Arxutils_Sqlite3::Config::CONFIG_DIR,
        'dbconfig' => Arxutils_Sqlite3::Config::DBCONFIG_SQLITE3,
        'env' => env,
        'log_fname' => Arxutils_Sqlite3::Config::DATABASELOG,
        'output_dir' => ::Everythingop::OUTPUT_DIR,
        'pstore_dir' => ::Everythingop::PSTORE_DIR
      }
    end

    def setup_config
      puts 'cli#setup_config'
    end

    def cli_setup_config
      setup_config
    end

    def cli_eto
      raise unless @group_file
      raise unless @infile

      Everythingop.new(@hash, @group_file, @infile)
    end

    def cli_f
      puts '################ cli_f 1'
      # eto = Everythingop::Everythingop.new( hash, @infile )
      eto = cli_eto
      puts '################ cli_f 2'

      eto.set_mode(@mode)
      puts '################ cli_f 3'
      eto.reset_hieritem_in_repo
      puts "################ cli_f 4 @mode=#{@mode}"
      # puts mode
      case @mode
      when :MIXED_MODE, :TRACE_MODE
        puts '== ensure_invalid'
        puts '################ cli_f MIXED_MODE TRACE_MODE 1'
        eto.ensure_invalid
        puts '################ cli_f MIXED_MODE TRACE_MODE 2'

        # 分類基準の復元
        restore_criteria(group_criteria, level)
      else
        puts '################ cli_f ELSE'
        # no op
      end
    end

    def setup_for_startup
      @hash = setup

      @mode = :MIXED_MODE
      # :TRACE_MODE
      # :ADD_ONLY_MODE
      # :DELETE_ONLY_MODE
      # :MIXED_MODE (default value)
    end

    # CLI実行
    def startup
      setup_for_startup

      case @cmd
      when 's'
        cli_setup_config
      when 'f'
        cli_f
      else
        puts 'Invalid command 2'
        puts banner
      end
    end
  end
end
