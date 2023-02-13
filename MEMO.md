Criteria
level: level, key: x[0], value: x[1]

         Dbutil::Category.create(name: x[0].to_s, path: x[1], hier: x[0].to_s) unless current_category
        hs = { name: category_name, path: path, hier: hier }
# gut
     @group = nil
      # グループの分類基準
      @group_criteria = nil
      # グループの分類基準（外部用）
      @group_criteria_external =
      # グループの分類基準（ディレクトリ/v/ext2）
      @group_criteria_v_ext2 = nil

      # リポジトリ配列
      @repo_ary = []




