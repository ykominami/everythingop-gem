# -*- coding: utf-8 -*-
#require 'arxutils'
require 'everythingop/dbutil/everythingop_init'
require 'pathname'
require 'pp'

module Everythingop
  module Dbutil 
    class Count  < ActiveRecord::Base
      has_and_belongs_to_many :repos
      has_and_belongs_to_many :categories
      has_and_belongs_to_many :currentrepos
      has_and_belongs_to_many :currentcategories
      has_many :invalidrepos
      has_many :invalidcategories
    end

    class Repo < ActiveRecord::Base
      has_and_belongs_to_many :Counts
      belongs_to :category , foreign_key: 'category_id'
      belongs_to :count , foreign_key: 'count_id'      
    end

    class Invalidrepo < ActiveRecord::Base
      belongs_to :repos , foreign_key: 'org_id'      
      belongs_to :counts , foreign_key: 'count_id'      
    end

    class Currentrepo < ActiveRecord::Base
      has_and_belongs_to_many :Counts
      belongs_to :counts , foreign_key: 'count_id'      
    end
    
    class Category < ActiveRecord::Base
      has_and_belongs_to_many :Counts
      has_many :repos
    end
    
    class Invalidcategory < ActiveRecord::Base
      belongs_to :categories , foreign_key: 'org_id'      
      belongs_to :counts , foreign_key: 'count_id'      
    end

    class Currentcategory < ActiveRecord::Base
      belongs_to :counts , foreign_key: 'count_id'      
      belongs_to :categories , foreign_key: 'org_id'
    end

    class TransactState
      attr_reader :ids
      
      def initialize
        @state = :NONE
        @ids = []
      end

      def add( xid )
        @ids << xid
      end

      def clear
        @ids = []
      end

      def need?
        @state != :NONE or @ids.size > 0
      end

      def start
        @state = :START
      end

      def stop
        @state = :STOP
      end

      def reset
        @state = :NONE
      end
    end

    class TransactStateGroup
      def initialize( *names )
        @inst = {}
        names.map{|x| @inst[x] = TransactState.new }
      end

      def method_missing(name , lang = nil)
        @inst[name]
      end
    end
    
    class Everythingop
      attr_reader :group , :group_v_ext2
      
      def initialize( kind, hs , fname = nil)
        @ts = TransactStateGroup.new( :category , :repo )
        
        @categoryinfo_hs_by_symbol = {}
        @category_hs_by_symbol = {}
        @repoinfo_array = []
        if fname
          @fname = fname
          @lines = File.readlines( @fname ).map{|x| x.strip }
        else
          @lines = get_lines
        end
        @dbmgr = Arxutils::Store.init( kind , hs ){ | register_time |
          @count = Count.create( countdatetime: register_time )
        }
        @repo_ids = Set.new
        @category_ids = Set.new

        @group_criteria = nil
        @group_criteria_external = nil
        @group_criteria_v_ext2 = nil
        variable_init

        reorder_category
      end
      
      def get_lines
        ary = []
        io = IO.popen( %q!es -w -r "\.git$"!, "r")
        while l=io.gets
          ary << l.strip
        end
        ary
      end
      
      def ensure_invalid_data
        if @ts.category.need?
          ensure_invalid( Currentrepo , Invalidrepo , @ts.category.ids , @count.id )
          @ts.category..clear
          @ts.category.reset
        end
        
        if @ts.category.need?
          ensure_invalid( Currentrepo , Invalidrepo , @ts_category.ids , @count.id )
          @ts.category.clear
          @ts.category.reset
        end
        ensure_invalid( Currentcategory , Invalidcategory , @category_ids.to_a , @count.id )
      end
      
      def ensure_invalid( current_class , invalid_class , valid_id_array , count_id )
        invalid_ids = current_class.pluck(:org_id) - valid_id_array
        p "ensure_invalid=invalid_ids"
        p invalid_ids
        p "ensure_invalid=valid_id_array"
        p valid_id_array
      end
      
      def reorder_category
        @ts.category.start
        
        # parent_idをキーとして、Categoryのインスタンスをグループ分け(Categoryのインスタンスの配列)
        @category_hs_by_parent_id = restore_category
        @category_hs_by_parent_id.map{|x|
          x[1].map{|y|
            @category_hs_by_symbol[y.name.to_sym] = y
          }
        }
        # parent_idが0のもの
        category_group_by_parent = @category_hs_by_parent_id.group_by{ |x| x[0] == 0 ? :zero : :not_zero }
        if category_group_by_parent[:zero] and category_group_by_parent[:zero].size > 0
          ary = category_group_by_parent[:zero].first
          # ary[0]は0、ary[1]はCategoryのインスタンスの配列
          @group_criteria_re = make_group_criteria( 0, @group_criteria ,  Hash[ *ary ] )
        else
          @group_criteria_re = make_group_criteria( 0, @group_criteria ,  {} )
        end
        
        # gitリポジトリのトップディレクトリをCategoryとして登録
        v_ext2_top_category = register_category( @v_ext2_top_symbol.to_s , 0, @group_criteria[@v_ext2_top_symbol].first )
        # parent_idが0以外のもの
        #  DBに存在する場合
        if category_group_by_parent[:not_zero] and category_group_by_parent[:not_zero].size > 0
          # TODO: 複数のサブ分類に対応すべき
          # TODO: DB中のCategoryにparent_idが0のみ(rootのみ)しか存在しないとここが呼ばれない場合への対応
          category_group_by_parent[:not_zero].map{|x|
            parent_id = x[0]
            if parent_id == v_ext2_top_category.id
              @group_criteria_re_v_ext2 = make_group_criteria( v_ext2_top_category.id , @group_criteria_v_ext2 , {x[0] => x[1]} )
            end
          }

        else
          #  DBに存在しない場合          
          @group_criteria_re_v_ext2 = make_group_criteria( v_ext2_top_category.id , @group_criteria_v_ext2 , {} )
        end
        @ts.category.stop
      end
      
      def make_group_criteria( parent_id, hs , db_hs )
        keys_in_db_only = db_hs.keys - hs.keys
        
        ary1 = keys_in_db_only.map{|k|
          db_hs[k].map{|x|
            it = [x.name.to_sym , Regexp.new(Regexp.escape( x.path )) , x.path]
            @categoryinfo_hs_by_symbol[x.name.to_sym] = it
            it
          }
        }.flatten(1)
        ary2 = hs.map{ |x|
          k = x[0]
          v = x[1]
          v = v.first if v.class == Array
          it = [k , Regexp.new(Regexp.escape(v)) , v]
          @categoryinfo_hs_by_symbol[k] = it
          register_category( k , parent_id , v )
          it
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
        Category.all.group_by{ |category| category.parent_id }
      end
      
      #====================================================
      
      #====================================================      
      def register_category( category_name , parent_id , path )
        category = Category.where( name: category_name ).first
        if category == nil 
          category = add_category( category_name , parent_id, path )
          category.save
        else
          hs = {}
          if category.name != category_name
            hs[:name] = category_name
          end
          if category.parent_id != category
            hs[:parent_id] = parent_id
          end
          if category.path != path
            hs[:path] = path
          end
          if hs.size > 0
            category.update( hs )
            category.save
          end
        end
        @ts.category.add( category.id )
        category
      end

      def add_repo( category_id , desc, path , mtime , ctime )
        hs = { category_id: category_id , desc: desc, path: path , mtime: mtime , ctime: ctime }
        Repo.create( hs )
      end

      def add_category( name , parent_id , path )
        hs = { name: name , parent_id: parent_id , path: path }
        Category.create( hs )
      end

      def delete_keys( hs , keys )
        keys.map{ |key| 
          hs.delete(key)
        }
      end
      
      def register_repo_without_desc( category_id , path , mtime, ctime )
        repo = Repo.where( path: path ).first
        if repo == nil 
          repo = add_repo( category_id , nil, path , mtime, ctime )
          if repo
            repo.save
          else
            p "= register_repo_without_desc = repo"
            p repo
          end
        else
          if category_id != repo.category_id
            p "= register_repo_without_desc = category_id=#{category_id}|repo.category_id=#{repo.category_id}"
            #          update_repo( repo, { :category_id => category_id } )
            #          repo.save
          end
        end
        @ts.repo.add( repo.id )
        repo
      end

      #====================================================      
      #====================================================      
      def get_all_repo
        @ts.repo.start
        
        if @repoinfo_array.size == 0
          
          @group = grouping( @lines , @group_criteria_re )
          delete_keys( @group , @category_exclude_hs.keys.map{|x| x.to_s } )
          
          sym = @v_ext2_top_symbol
          if @group[ sym  ]
            array = @group.delete( sym )
            @group_v_ext2 = grouping( array , @group_criteria_re_v_ext2 )
            @group_v_ext2.map{ |x|
              category = Category.where( name: x[0] ).first
              x[1].each do |l|
                pn = Pathname.new(l)
                register_repo_without_desc( category.id , pn.to_s , pn.mtime, pn.ctime )
              end
            }
          end
        end
        @ts.repo.stop
      end

      def listup_repo
        get_all_repo
        
        repos = Repo.pluck(:id)
        if repos.max
          Repo.all
        else
          []
        end
      end

      def show_all_repo
        Repo.all.each do |x|
          puts %Q!#{sprintf("% 4d" , x.id)}|#{x.category.name}|#{x.desc}|#{x.path}|#{x.mtime}|#{x.ctime}!
        end
      end
      #====================================================      
    end
  end
end
