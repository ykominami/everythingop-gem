require 'arxutils_sqlite3'
require 'forwardable'
require 'everythingop/dbutil'
# require 'everythingop/everythingop_init'
require 'pathname'
require 'pp'
require 'csv'
require 'yaml'

module Everythingop
  # Everything用操作クラス
  class Everythingop
    extend Forwardable

    def_delegator(:@hierop, :register, :register_categoryhier)
    def_delegator(:@hierop, :delete, :unregister_categoryhier)
    def_delegator(:@hierop, :move, :move_categoryhier)

    # グループ(ルート)
    attr_reader :group
    # グループv_ext2
    attr_reader :group_v_ext2

    # カテゴリクラスに対する階層操作
    @hierop = Arxutils_Sqlite3::HierOp.new('hier', :hier, 'hier', Dbutil::Category, Dbutil::Categoryhier, Dbutil::Currentcategory, Dbutil::Invalidcategory)
    # 階層を表すアイテムクラス
    @hieritem = Struct.new(:field_name, :hier_symbol, :base_asoc_name, :base_klass, :hier_klass, :cur_klass, :invalid_klass, :op_inst)
    # 階層を表すアイテム配列

    # 階層を表すアイテムクラスのインスタンス
    def self.make_instance_of_hireitem(field_name, hier_symbol, base_asoc_name, base_klass, hier_klass, cur_klass, invalid_klass, op_inst = nil)
      @hieritem.new(field_name, hier_symbol, base_asoc_name, base_klass, hier_klass, cur_klass, invalid_klass, op_inst)
    end

    # 初期化
    def initialize(hash, group_fname, infname)
      raise unless group_fname
      raise unless infname

      @hieritem_ary = [
        self.class.make_instance_of_hireitem('hier1item_id', :hier, 'hier1item', Dbutil::Hier1item, Dbutil::Hier1, Dbutil::Currenthier1item, Dbutil::Invalidhier1item),
        self.class.make_instance_of_hireitem('hier2item_id', :hier, 'hier2item', Dbutil::Hier2item, Dbutil::Hier2, Dbutil::Currenthier2item, Dbutil::Invalidhier2item),
        self.class.make_instance_of_hireitem('hier3item_id', :hier, 'hier3item', Dbutil::Hier3item, Dbutil::Hier3, Dbutil::Currenthier3item, Dbutil::Invalidhier3item)
      ]
      @hieritem_ary.map do |x|
        x.op_inst = Arxutils_Sqlite3::HierOp.new(x.field_name, x.hier_symbol, x.base_asoc_name, x.base_klass, x.hier_klass, x.cur_klass, x.invalid_klass)
      end
      # 階層を表すアイテムハッシュ
      @hieritem_hs = @hieritem_ary.each_with_object({}) do |x, memo|
        memo[x.field_name] = x.op_inst
      end
      # グループ情報設定
      setup_for_group(group_fname)
      # トランザクショングループ作成
      @tsg = setup_for_transact_state_group(infname)
      setup_for_db(hash)
    end

    # グループ分類情報設定
    def setup_for_group(group_fname)
      # グループ
      @group = nil
      # グループの分類基準
      @group_criteria = nil
      # グループの分類基準（外部用）
      @group_criteria_external = nil
      # グループの分類基準（ディレクトリ/v/ext2）
      @group_criteria_v_ext2 = nil

      # リポジトリ配列
      @repo_ary = []
      scope = Object.new
      value_hash = {}
      in_content = Ykutils::Erubyx.erubi_render_with_template_file(group_fname, scope, value_hash)
      hash = Ykxutils.yaml_load_compati(in_content)

      @group = nil
      # グループの分類基準
      @group_criteria = hash['group_criteria']
      # グループの分類基準（外部用）
      @group_criteria_external = hash['group_criteria_external']
      # グループの分類基準（ディレクトリ/v/ext2）
      @group_criteria_v_ext2 = hash['group_criteria_v_ext2']
      @z_hier = hash['z_hier']
      @category_exclude_ary = hash['category_exclude_ary']
      puts "group_fname=#{group_fname}"
      puts "in_content=#{in_content}"
      puts "hash=#{hash}"
      hash_two = YAML.safe_load(in_content)
      puts "hash_two=#{hash_two}"
      puts "@group_criteria=#{@group_criteria}"
      puts "@group_criteria_external=#{@group_criteria_external}"
      # exit
    end

    # トランザクショングループ設定
    def setup_for_transact_state_group(infile)
      # トランザクショングループ
      tsg = Arxutils_Sqlite3::TransactStateGroup.new(:category, :repo, :hier1item, :hier2item, :hier3item)
      # トランザクショングループ化したい情報を持つファイルのファイル名
      # @fname = fname
      # トランザクショングループ化したい情報の配列
      puts('#### Everythingop::Everythingop.new =1')
      @lines = File.readlines(infile).map(&:strip).shift(300)
      puts("@lines.size=#{@lines.size}")
      puts('#### Everythingop::Everythingop.new =2')
      # pp @lines

      tsg
    end

    # DB設定
    def setup_for_db(hash)
      db_dir = hash['db_dir']
      config_dir = hash['config_dir']
      env = hash['env']
      dbconfig = hash['dbconfig']

      dbconfig_path = Arxutils_Sqlite3::Util.make_dbconfig_path(config_dir, dbconfig)
      log_path = Arxutils_Sqlite3::Util.make_log_path(db_dir, dbconfig)
      dbconnect = Arxutils_Sqlite3::Dbutil::Dbconnect.new(
        dbconfig_path,
        env,
        log_path
      )
      register_time = dbconnect.connect
      # 保存用DBマネージャ
      @dbmgr = Dbutil::EverythingopMgr.new(register_time)
    end

    # トランザクションモード設定
    def set_mode(mode = :MIXED_MODE)
      @mode = mode
      # :TRACE_MODE
      # :ADD_ONLY_MODE
      # :DELETE_ONLY_MODE
      # :MIXED_MODE (default value)

      case @mode
      when :TRACE_MODE
        @tsg.trace
      when :ADD_ONLY_MODE
        @tsg.reset
      when :DELETE_ONLY_MODE
        @tsg.reset
      else
        # :MIXED_MODE
        @tsg.reset
      end
    end

    # 分類基準の復元
    def restore_criteria(group_criteria, level)
      criteria = Dbutil::Criteria.where(level: level).all.each_with_object({}) do |x, s|
        s[x.key] = x.value
      end
      if criteria.size.positive?
        group_criteria = criteria
      else
        group_criteria.map { |x| Dbutil::Criteria.create(level: level, key: x[0], value: x[1]) }
      end
      group_criteria
    end

    # 階層構造の再分類
    def reorder_hier
      @hieritem_ary.zip(@z_hier).map do |x|
        hi = x[0]
        data = x[1]

        hs_count = hi.hier_klass.group(:parent_id).count(:parent_id)
        if hs_count.size.zero?
          data.map do |name|
            register_hieritem(hi, name)
          end
          hi.cur_klass.pluck(:hier).map do |y|
            hi.op_inst.register(y)
          end
          hs_count = hi.hier_klass.group(:parent_id).count(:parent_id)
        end
        hs_count.keys.each_with_object({}) do |x2, memo|
          memo[x2] = Dbutil::Category.find(Dbutil::Categoryhier.where(parent_id: x2).pluck(:child_id))
        end
      end
    end

    # カテゴリの再分類
    def reorder_category
      hs_count = Dbutil::Categoryhier.group(:parent_id).count(:parent_id)

      category_hs_by_parent_id = hs_count.keys.each_with_object({}) do |x, hs|
        hs[x] = Dbutil::Category.find(Dbutil::Categoryhier.where(parent_id: x).pluck(:child_id))
      end

      # parent_idが0のもの
      category_group_by_parent = category_hs_by_parent_id.group_by { |x| x[0] == 1 ? :one : :not_one }

      @group_criteria = restore_criteria(@group_criteria, 1)
      _tmp, _tmp2, @v_ext2_git_top_category_id = [
        [:"", '', ''],
        [:'/ext2', '', '/ext2'],
        [:'/ext2/git', '', '/ext2/git']
      ].map do |x|
        @group_criteria.delete(x[0])
        register_category(*x)
      end
      @group_criteria_v_ext2 = restore_criteria(@group_criteria_v_ext2, 2)

      [@group_criteria, @group_criteria_v_ext2].map do |y|
        y.map do |x|
          current_category = Dbutil::Currentcategory.find_by(hier: x[0].to_s)
          Dbutil::Category.create(name: x[0].to_s, path: x[1], hier: x[0].to_s) unless current_category
        end
      end

      # 親分類(:one)に含まれるカテゴリグループが存在すれば、グループの先頭の配列
      #
      if category_group_by_parent[:one]&.size&.positive?
        ary = category_group_by_parent[:one].first[1]

        db_hs = ary.each_with_object({}) do |x, s|
          s.update(x.hier.to_sym => x)
        end
        @group_criteria_re = make_group_criteria(@group_criteria,  db_hs)
      else
        @group_criteria_re = make_group_criteria(@group_criteria,  {})
      end

      # gitリポジトリのトップディレクトリをCategoryとして登録
      #
      @group_criteria_re_v_ext2 = make_group_criteria(@group_criteria_v_ext2, {})
      # カテゴリの階層構造設定
      set_categoryhier
    end

    # カテゴリの階層構造の設定
    def set_categoryhier
      Dbutil::Currentcategory.pluck(:hier).map do |x|
        @hierop.register(x)
      end
    end

    # グループ取得
    def retrive_group
      @category_exclude_ary.map do |key|
        @group_criteria_re.delete(key)
      end

      group = grouping(@lines, @group_criteria_re)
      group.select { |x| !x.nil? and !x[0].nil? }.map do |x|
        current_category = Dbutil::Currentcategory.find_by(name: x[0].to_s)
        if current_category
          x[1].each do |l|
            pn = Pathname.new(l)
            begin
              pn.mtime
              register_repo_without_desc(current_category.category.id, pn.to_s, pn.mtime, pn.ctime)
            rescue StandardError => e
              puts e.message
              pp e.backtrace
              p l
            end
          end
        end

        set_hier
      end
      group
    end

    # 全リポジトリ取得
    def all_repo
      @group ||= retrive_group

      data = @group[:""]
      data ||= @group[nil]
      return unless data

      @group_v_ext2 = grouping(data, @group_criteria_re_v_ext2)
      @group_v_ext2.select { |x| !x.nil? and !x[0].nil? }.map do |x|
        current_category = Dbutil::Currentcategory.find_by(name: x[0].to_s)
        next unless current_category

        x[1].each do |l|
          pn = Pathname.new(l)
          begin
            pn.mtime
            register_repo_without_desc(current_category.category.id, pn.to_s, pn.mtime, pn.ctime)
          rescue StandardError => e
            puts e.message
            pp e.backtrace
            p current_category
            p l
          end
        end
      end
    end

    # カテゴリ一覧取得
    def list_category
      cur = Dbutil::Currentcategory.where(hier: '/stack_root/1').first
      _ch = Dbutil::Categoryhier.find_by(child_id: cur.category.id)

      Dbutil::Currentcategory.pluck(:name, :path, :path)
    end

    # リポジトリ一覧取得（その1）
    def list_repo_one
      all_repo

      repos = Dbutil::Currentrepo.pluck(:org_id)
      if repos.size.positive?
        Dbutil::Repo.find(repos)
      else
        []
      end
    end

    # リポジトリ一覧取得（その２）
    def list_repo_two
      all_repo

      Dbutil::Currentcategory.all.map do |x|
        category = x.category
        puts category.name
        category.repos.map { |y| puts %( #{y.path}|#{y.desc}) }
      end
    end

    # リポジトリ一覧取得
    def list_repo
      all_repo

      Dbutil::Categoryhier.where(parent_id: @v_ext2_git_top_category_id).pluck(:child_id).map do |x|
        category = Dbutil::Category.find(x)
        ary = category.repos
        next unless ary.size.positive?

        puts category.name.to_s
        ary.map do |y|
          puts %( #{y.path}|#{y.desc})
        end
      end
    end

    # hier1itemでパス指定によリポジトリ削除
    def unset_repo_by_path_in_hier1item(src_path)
      unset_repo_by_path_in_hieritem(0, src_path)
    end

    # hier2itemでパス指定によリポジトリ削除
    def unset_repo_by_path_in_hier2item(src_path)
      unset_repo_by_path_in_hieritem(1, src_path)
    end

    # hier3itemでパス指定によリポジトリ削除
    def unset_repo_by_path_in_hier3item(src_path)
      unset_repo_by_path_in_hieritem(2, src_path)
    end

    # hieritemでパス指定によリポジトリ削除
    def unset_repo_by_path_in_hieritem(num, src_path)
      repo = Dbutil::Currentrepo.find_by(path: src_path).repo
      unset_repo_in_hieritem(num, repo)
    end

    # hieritemのID指定によリポジトリ削除
    def unset_repo_in_hieritem(num, repo)
      hi_info = @hieritem_ary[num]
      if repo
        hs = { hi_info.field_name.to_sym => nil }
        repo.update(hs)
      else
        puts "Can't find #{dest_hier} in #{num}"
      end
    end

    # hier1itemでパス指定によりリポジトリ移動
    def move_repo_by_path_in_hier1item_by_path(_src_path, _dest_hier_path)
      move_repo_by_path_in_hieritem(0, srcr_path, dest_hierr_path)
    end

    # hier2itemでパス指定によりリポジトリ移動
    def move_repo_by_path_in_hier2item_by_path(srcr_path, dest_hierr_path)
      move_repo_by_path_in_hieritem(1, srcr_path, dest_hierr_path)
    end

    # hier3itemでパス指定によりリポジトリ移動
    def move_repo_by_path_in_hier3item_by_path(srcr_path, dest_hierr_path)
      move_repo_by_path_in_hieritem(2, srcr_path, dest_hierr_path)
    end

    # hieritemでパス指定によりリポジトリ移動
    def move_repo_by_path_in_hieritem_by_path(num, srcr_path, dest_hierr_path)
      repo = Dbutil::Currentrepo.find_by(path: srcr_path).repo
      move_repo_in_hieritem(num, repo, dest_hierr_path)
    end

    # IDで指定した階層を表すアイテムを利用して、リポジトリをパス指定により移動
    def move_repo_in_hieritem_by_path(num, repo, dest_hierr_path)
      puts "dest_hier=#{dest_hierr_path}"
      hi_info = @hieritem_ary[num]
      hs_target = { hi_info.hier_name => dest_hierr_path }
      hi = hi_info.cur_klass.find_by(hs_target)
      move_repo_in_hieritem(hi_info, repo, hi)
    end

    # hieritemでhieritemのIDで指定したリポジトリを、パス指定により移動
    def move_repo_in_hieritem(hi_info, repo, hier)
      if hier
        hieritem = hier.__send__ hier_info.base_asoc_name
        hs = { hi_info.field_name.to_sym => hieritem.id }
        repo.update(hs)
      else
        puts "Can't find #{dest_hier} in #{num}"
      end
    end

    # Hieritemクラス内でのリポジトリの移動
    def move_in_hieritem(src, dest_hier); end

    # カレントのリポジトリの一覧
    def list_hierx
      hs = Dbutil::Currentrepo.all.each_with_object({}) do |x, s|
        repo = x.repo
        @hieritem_ary.map do |y|
          sym = y.base_asoc_name.to_sym
          s[sym] ||= {}
          hieritem = repo.__send__ y.base_asoc_name
          s[sym][hieritem] ||= []
          s[sym][hieritem] << repo
        end
      end
      @hieritem_ary.map do |y|
        sym = y.base_asoc_name.to_sym
        puts "hs.keys=#{hs.keys}"

        array = hs[sym].keys.sort_by do |a, b|
          if !a.nil?
            if b.nil?
              1
            else
              a.hier <=> b.hier
            end
          elsif !b.nil?
            -1
          else
            0
          end
        end
        array.map do |z|
          if z
            puts z.__send__ y.hier_name
          else
            puts 'nil'
          end
          hs[sym][z].map do |a|
            puts %(  #{a.path}|#{a.desc})
          end
        end
      end
    end

    # hier1の一覧
    def list_hier_one(hieritem)
      array = hieritem.cur_klass.all.order(:hier).select do |x|
        (x.__send__ hieritem.base_asoc_name).repos.size.positive?
      end
      array.map do |x|
        hi = x.__send__ hieritem.base_asoc_name
        puts hi.hier.to_s
        hi.repos.map do |y|
          puts %( #{y.path}|#{y.desc})
        end
      end
      puts ''
    end

    # hieritemの一覧
    def list_hier(hieritem)
      ary = hieritem.cur_klass.all.order(:hier).each_with_object([]) do |x, s|
        hi = (x.__send__ hieritem.base_asoc_name)
        s << [hi, hi.repos] if hi.repos.size.positive?
      end
      return if ary.size.zero?

      puts %(* #{hieritem.base_asoc_name})
      ary.map do |x|
        hi, repos, _tmp = x
        puts hi.hier.to_s
        repos.map do |y|
          puts %( #{y.path}|#{y.desc})
        end
      end
      puts ''
    end

    # 指定カテゴリを無効にする
    def invalidate_category(name)
      id = Dbutil::Currentcategory.where(name: name).pluck(:org_id).first
      if id
        Dbutil::Invalidcategory.create(org_id: id, count_id: @count.id)
        unregister_categoryhier(name)
      end
      id
    end

    # 無効にすべきものをすべて無効化する
    def ensure_invalid
      invalid_ids = Dbutil::Currentrepo.pluck(:org_id) - @tsg.repo.ids
      invalid_ids.map do |x|
        Dbutil::Invalidrepo.create(org_id: x, count_id: @count.id)
      end

      invalid_ids = Dbutil::Currentcategory.pluck(:org_id) - @tsg.category.ids
      invalid_ids.map do |x|
        Dbutil::Invalidcategory.create(org_id: x, count_id: @count.id)
        unregister_category(Category.find(x).hier)
      end
    end

    # 有効な全リポジトリ表示
    def show_all_repo
      Dbutil::Currentrepo.all.each do |x|
        puts %(#{format('% 4d', x.id)}|#{x.repo.category.name}|#{x.desc}|#{x.path}|#{x.mtime}|#{x.ctime})
      end
    end

    # リポジトリの情報をCSVファイルに出力
    def save_repo
      fname = 'repo.tsv'
      header = ['id', 'category_id', 'desc', 'path', 'mtime', 'ctime', 'hier1item_id', 'hier2item_id', 'hier3item_id', 'created_at', 'updated_at']
      CSV.open(fname, 'w', { :col_sep => "\t", :headers => header }) do |csv|
        @repo_ary.map { |x| csv << x }
      end
    end

    # 有効なリポジトリに対してhier1item_id, hier2item_id, hier3item_idを割り振る（テストデータ作成用）
    def set_hier
      Dbutil::Currentrepo.all.reduce(1) do |s, x|
        hs = { :hier1item_id => s, :hier2item_id => (s + 1), :hier3item_id => (s + 2) }
        p hs
        x.repo.update(hs)
        (s + 3)
      end
    end

    # リポジトリのbase_asoc_nameを無効にする(テストデータ作成用)
    def reset_hieritem_in_repo
      Dbutil::Repo.all.map do |x|
        hs = @hieritem_ary.each_with_object({}) do |y, s|
          s[y.base_asoc_name.to_sym] = nil
        end
        puts 'Everythingop.reset_hieritem_in_repot='
        puts "hs=#{hs}"
        x.update(hs)
      end
    end

    # JSON形式でカテゴリの階層構造を得る
    def category_hier_jsondata
      JSON(Dbutil::Categoryhier.pluck(:parent_id, :child_id, :level).map do |ary|
        text = Dbutil::Category.find(ary[1]).hier.split('/').pop
        parent_id = if (ary[2]).zero?
                      '#'
                    else
                      (ary[0]).to_s
                    end
        child_id = (ary[1]).to_s
        { 'id' => child_id, 'parent' => parent_id, 'text' => text }
      end)
    end

    private

    # group_criteriaの設定
    def make_group_criteria(hs_base, db_hs)
      keys_in_db_only = db_hs.keys - hs_base.keys

      hs1 = hs_base.reduce({}) do |hsx, x|
        hsx.update(x[0] => Regexp.new(Regexp.escape(x[1])))
      end
      hs2 = keys_in_db_only.reduce({}) do |hsx, k|
        hsx.update(k => Regexp.new(Regexp.escape(db_hs[k].path)))
      end
      keys_in_hs_only = hs_base.keys - db_hs.keys
      keys_in_hs_only.map do |x|
        v = hs_base[x]
        register_category(x.to_s, v, x.to_s)
      end
      hs1.merge(hs2)
    end

    # グルーピング
    def grouping(data, group_criteria_re)
      data.group_by do |x|
        obj = group_criteria_re.find do |c|
          c[1].match(x)
        rescue StandardError => e
          puts e.message
          puts "c[1].encoding=#{c[1].encoding}"
          puts "x.encoding=#{x.encoding}"
          exit
        end
        ret = obj ? obj[0] : nil
        ret
      end
    end

    # カテゴリ登録
    def register_category(category_name, path, hier)
      category_id = nil
      current_category = Dbutil::Currentcategory.find_by(name: category_name)
      if current_category.nil?
        hs = { name: category_name, path: path, hier: hier }
        begin
          category = Dbutil::Category.create(hs)
          category_id = category.id
        rescue StandardError => e
          p 'In register_category'
          p e.class
          p e.message
          pp e.backtrace
        end
      else
        category_id = current_category.category.id
        hs = {}
        hs[:path] = path if current_category.category.path != path
        hs[:hier] = hier if current_category.category.hier != hier
        current_category.category.update(hs) if hs.size.positive?
      end
      @tsg.category.add(category_id) if category_id
      category_id
    end

    # hieritem登録
    def register_hieritem(hieritem, hier)
      id = nil
      hs = { hieritem.hier_name => hier }
      cur = hieritem.cur_klass.find_by(hs)
      if cur.nil?
        begin
          item = hieritem.base_klass.create(hs)
          id = item.id
        rescue StandardError => e
          p 'In register_hier'
          p e.class
          p e.message
          pp e.backtrace
        end
      else
        met = hieritem.base_asoc_name
        id = (cur.__send__ met).id
      end
      if id
        met = hieritem.base_asoc_name
        (@tsg.__send__ met).add(id)
      end
      id
    end

    # categoryhierの登録
    def ensure_categoryhier
      Dbutil::Category.pluck(:hier).map do |x|
        register_categoryhier(x)
      end
    end

    # リポジトリを説明記述なしで登録(テストデータ作成用)
    def register_repo_without_desc(category_id, path, mtime, ctime)
      repo_id = nil
      current_repo = Dbutil::Currentrepo.find_by(path: path)
      if current_repo.nil?
        begin
          _hs = { category_id: category_id, path: path, mtime: mtime, ctime: ctime }
          # ["id","category_id","desc","path","mtime","ctime","hier1item_id","hier2item_id","hier3item_id","created_at","updated_at"]
          repo_id = @repo_ary.size + 1
          time = '2016-06-12 03:55:47'
          @repo_ary << [repo_id, category_id, path, mtime, ctime, nil, nil, nil, time, time]
        #          repo = Repo.create( hs )
        #          repo_id = repo.id
        rescue StandardError => e
          p e.class
          p e.message
          pp e.backtrace
          repo_id = nil
          exit
        end
      else
        repo_id = current_repo.repo.id
        update_integer(current_repo.repo, { :category_id => category_id }) if category_id != current_repo.repo.category_id
      end

      @tsg.repo.add(repo_id) if repo_id

      repo_id
    end
  end
end
