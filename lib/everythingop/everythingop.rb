# -*- coding: utf-8 -*-
require 'everythingop/dbutil/everythingop_ac'
require 'everythingop/everythingop_init'
require 'everythingop/dbutil/everythingopmgr'
require 'pathname'
require 'forwardable'

module Everythingop
  class Everythingop
    attr_reader :group , :group_v_ext2

    extend Forwardable
    
    def_delegator( :@mgr , :add , :db_add )
    def_delegator( :@mgr , :add_category , :db_add_category )
    def_delegator( :@mgr , :restore_category , :db_restore_category )
    def_delegator( :@mgr , :ensure_invalid, :db_ensure_invalid)
=begin    
    def_delegator( :@mgr , :update_add_date, :dg_update_add_date)
    def_delegator( :@mgr , :update_last_modified, :db_update_last_modified)
    def_delegator( :@mgr , :get_add_date_from_management, :db_get_latest_add_date)
    def_delegator( :@mgr , :get_last_modified_from_management, :db_get_latest_last_modified)
    def_delegator( :@mgr , :update_management, :db_update_management)
=end
    def initialize( kind, hs , fname )
      @repoinfo_array = []
      @categoryinfo_array = []
      @categoryinfo_hs_by_path = {}
      @repoinfo_hs_by_path = {}
      @categoryinfo_hs_by_symbol = {}
      @repoinfo_hs_by_symbol = {}
      @categoryinfo_hs_by_id = {}
      @category_hs = {}
      @category_hs_by_parent_id = {}

      @fname = fname
      @lines = File.readlines( @fname ).map{|x| x.strip }
      @group = nil
      @group_v_ext2 = nil
      @git_repository_top=%q!V:\ext2!

      @repoinfo = Struct.new("Reponfo", :category_id, :path, :mtime, :ctime)
      @categoryinfo = Struct.new("CategoryInfo", :name, :parent_id, :path , :category_id)

      @group = nil

      @group_criteria = nil
      @group_criteria_external = nil
      @group_criteria_v_ext2 = nil
      variable_init
      
      @dbmgr = Arxutils::Store.init( kind , hs ){ | register_time |
        @mgr = Dbutil::EverythingopMgr.new( register_time )
      }
      @category_hs_by_parent_id = restore_category
      @category_hs_by_parent_id_0_by_name = @category_hs_by_parent_id[0]
      
      puts "------------------------X"
      p @category_hs_by_parent_id
      category_group_by_parent = @category_hs_by_parent_id.keys.group_by{ |x| x == 0 ? :zero : :not_zero }
      if category_group_by_parent[:zero] and category_group_by_parent[:zero].size > 0
        category = @category_hs_by_parent_id[ category_group_by_parent[:zero].first ]
        puts "------------------------0"
        p category.class
#        @group_criteria_re = make_group_criteria( @group_criteria ,  Hash[*category] )
        @group_criteria_re = make_group_criteria( @group_criteria ,  category )
        p @group_criteria_re
      end
      
      if category_group_by_parent[:not_zero] and category_group_by_parent[:not_zero].size > 0
        category_group_by_parent[:not_zero].map{ |parent_id|
          # TODO: 複数のサブ分類に対応すべき
          # TODO: DB中のCategoryにparent_idが0のみ(rootのみ)しか存在しないとここが呼ばれない場合への対応
          puts "------------------------1(#{k})"
          @group_criteria_re_v_ext2 = make_group_criteria( @group_criteria_v_ext2 , @category_hs_by_parent_id[parent_id] )
          p @group_criteria_re_v_ext2
        }
      else
          @group_criteria_re_v_ext2 = make_group_criteria( @group_criteria_v_ext2 , {} )
      end

    end

    def make_group_criteria( hs , db_hs )
      p "=hs"
      p hs.class
      p hs

      p "=db_hs"
      p db_hs.class
      p db_hs
      keys_in_db_only = db_hs.keys - hs.keys

      ary1 = keys_in_db_only.map{|k|
        p k
        path = db_hs[k].path
        [k , Regexp.new(Regexp.escape( path )) , path]
      }
      ary2 = hs.map{ |x|
        k = x[0]
        v = x[1]
        v = v.first if v.class == Array
        [x , Regexp.new(Regexp.escape(v)) , v]
      }
      (ary1 + ary2)
    end
    
    def grouping( data , group_criteria_re )
      data.group_by{ |x|
        obj = group_criteria_re.find{|c|
          c[1].match(x)
        }
        obj ? obj[0] : nil
      }
    end

    def restore_category
      db_restore_category
    end

    def update_category
    end
    
    def get_all_category
      if @categoryinfo_array.size == 0
        @categoryinfo_array = @group_criteria.map{|x|
#            p x[0]
#            p x
            path = x[1].first
            it = @categoryinfo.new( x[0] ,0 , path )
            p it
            puts "=="
            @categoryinfo_hs_by_path[path] = it
            @categoryinfo_hs_by_symbol[x[0]] = it
            it
        }.select{ |x|
          x != nil
        }
        @categoryinfo_array.map{ |x|
          category_id = db_add_category(  x.name , x.parent_id , x.path )
          x.category_id = category_id
          @categoryinfo_hs_by_id[x.category_id] = x
        }
        # Gitリポジトリへの対応
        it = @categoryinfo_hs_by_path[ @group_criteria_v_ext2[@v_ext2_top_symbol] ]
        if it
          @group_criteria_re_v_ext2.map{|x|
            k = x[0]
            path = x[2]
            it = @categoryinfo.new( name: x[0] , parent_id: it.category_id , path: path )
            @categoryinfo_hs_by_path[path] = it
            @categoryinfo_hs_by_symbol[k] = it
            category_id = db_add_category(  it.name , it.parent_id , it.path )
            it
          }.select{ |x|
            x != nil
          }
        end
      end
      @categoryinfo_array
    end
    
    def register_repo( category_id , hs )
      hs.map{|x|
        x[1].map{ |path|
          pn = Pathname.new( path )
          @repoinfo.new( category_id , path , pn.mtime, pn.ctime )
        }.select{ |x|
          x != nil
        }
      }
    end

    def delete_keys( hs , keys )
      keys.map{ |key| 
        hs.delete(key)
      }
    end
    
    def get_all_repo
      if @repoinfo_array.size == 0
        @group = grouping( @lines , @group_criteria_re )
        delete_keys( @group , @category_exclude_hs.keys.map{|x| x.to_s } )
        sym = @v_ext2_top_symbol
        if @group[ sym  ]
          array = @group.delete( sym )
          @group_v_ext2 = grouping( array , @group_criteria_re_v_ext2 )
          @group_v_ext2.map{ |x|
            category = @categoryinfo_hs_by_symbol[x[0]]
            register_repo( category.id , @group_v_ext2 )
          }
        end
      end
    end
    
    def list_repo
      get_all_repo
      @repoinfo_array.map{ |repoinfo|
        db_add(  repoinfo.category_id , repoinfo.path , repoinfo.mtime , repoinfo.ctime )
      }
    end

    def list_desc
      get_all_desc
      @deescinfo_array.map{|descinfo|
        db_add_desc(  descinfo.repo_id , descinfo.path , descinfo.desc )
      }
    end
    
    def list_category
      get_all_category
      @categoryinfo_array.map{|category|
        db_add_category(  repoinfo.category_id , repoinfo.path , repoinfo.mtime , repoinfo.ctime )
      }
    end

    def ensure_invalid
      db_ensure_invalid
    end
  end
end
