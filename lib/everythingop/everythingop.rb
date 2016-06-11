# -*- coding: utf-8 -*-
require 'arxutils'
require 'forwardable'
require 'everythingop/relation'
require 'everythingop/everythingop_init'
require 'pathname'
require 'pp'

module Everythingop
  class Everythingop
    extend Forwardable
    include Arxutils
    
    def_delegator( :@hierop , :register , :register_categoryhier )
    def_delegator( :@hierop , :delete   , :unregister_categoryhier )
    def_delegator( :@hierop , :move     , :move_categoryhier )

    attr_reader :group , :group_v_ext2

    def initialize( kind, hs , fname = nil)
      @tsg = TransactStateGroup.new( :category , :repo )
      if fname
        @fname = fname
        @lines = File.readlines( @fname ).map{|x| x.strip }.shift(3000)
      else
        @lines = get_lines.shift(3000)
      end
      Store.init( kind , hs ){ | register_time |
        @count = Count.create( countdatetime: register_time )
      }
      @group = nil
      @group_criteria = nil
      @group_criteria_external = nil
      @group_criteria_v_ext2 = nil
      variable_init
    end

    def set_mode( mode = :MIXED_MODE )
      @hierop = HierOp.new( :hier , Category , Categoryhier, Currentcategory )
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

    def restore_criteria( group_criteria , level )
      criteria = Criteria.where( level: level ).all.reduce({}){ |s,x|
        s[ x.key ] = x.value
        s
      }
      if criteria.size > 0
        group_criteria = criteria
      else
        group_criteria.map{|x| Criteria.create( level: level , key: x[0], value: x[1] ) }
      end
      group_criteria
    end
    
    def reorder_category
      hs_count = Categoryhier.group(:parent_id).count(:parent_id)

      @category_hs_by_parent_id = hs_count.keys.reduce({}){ |hs, x|
        hs[x] = Category.find( Categoryhier.where( parent_id: x ).pluck( :child_id ) )
        hs
      }

      # parent_idが0のもの
      category_group_by_parent = @category_hs_by_parent_id.group_by{ |x| x[0] == 1 ? :one : :not_one }

      @group_criteria = restore_criteria( @group_criteria , 1 )
      tmp, tmp2, @v_ext2_git_top_category_id = [
        ["".to_sym          , '' , ''],
        ["/ext2".to_sym     , '' , '/ext2'],
        ["/ext2/git".to_sym , '' , '/ext2/git'],
      ].map{ |x|
        @group_criteria.delete( x[0] )
        register_category( *x )
      }
      @group_criteria_v_ext2 = restore_criteria( @group_criteria_v_ext2 , 2 )
      
      [@group_criteria , @group_criteria_v_ext2].map{ |y|
        y.map{ |x|
          current_category = Currentcategory.find_by( hier: x[0].to_s )
          unless current_category
            Category.create( name: x[0].to_s , path: x[1] , hier: x[0].to_s )
          end
        }
      }


      if category_group_by_parent[:one] and category_group_by_parent[:one].size > 0
        ary = category_group_by_parent[:one].first[1]

        # ary[0]は1、ary[1]はCategoryのインスタンスの配列
        db_hs = ary.reduce({}){ |s,x|
          s.update( x.hier.to_sym => x )
        }
        @group_criteria_re = make_group_criteria( @group_criteria ,  db_hs )
      else
        @group_criteria_re = make_group_criteria( @group_criteria ,  {} )
      end
      
      # gitリポジトリのトップディレクトリをCategoryとして登録
      #
      @group_criteria_re_v_ext2 = make_group_criteria( @group_criteria_v_ext2 , {} )
      # カテゴリの階層構造設定
      set_categoryhier
    end
    
    def set_categoryhier
      Currentcategory.pluck(:hier).map{|x|
        @hierop.register( x )
      }
    end
    
    #====================================================      
    def get_all_repo
      unless @group
        exclude = @category_exclude_hs.keys.map{|x| x }
        delete_keys( @group_criteria_re , exclude )
        
        @group = grouping( @lines , @group_criteria_re )
        @group.select{|x| x != nil and x[0] != nil }.map{ |x|
          current_category = Currentcategory.find_by( name: x[0].to_s )
          if current_category
            x[1].each do |l|
              pn = Pathname.new(l)
              begin
                pn.mtime
                register_repo_without_desc( current_category.category.id , pn.to_s , pn.mtime, pn.ctime )
              rescue => ex
                puts ex.message
                pp ex.backtrace
                p l
              end
            end
          end
        }
      end
      
      data = @group[:""]
      data = @group[nil] unless data
      if data
        @group_v_ext2 = grouping( data , @group_criteria_re_v_ext2 )
        @group_v_ext2.select{ |x| x != nil and x[0] != nil }.map{ |x|
          current_category = Currentcategory.find_by( name: x[0].to_s )
          if current_category
            x[1].each do |l|
              pn = Pathname.new(l)
              begin
                pn.mtime
                register_repo_without_desc( current_category.category.id , pn.to_s , pn.mtime, pn.ctime )
              rescue => ex
                puts ex.message
                pp ex.backtrace
                p current_category
                p l
              end
            end
          end
        }
      end
    end

    def list_category
      cur = Currentcategory.where( hier: "/stack_root/1" ).first
      p cur
      cc = cur.category
      p cc
      ccc = cc.parent_category.first
      p ccc
      Currentcategory.pluck( :name , :path , :path )
    end

    def list_repo
      get_all_repo
      
      repos = Currentrepo.pluck(:org_id)
      if repos.size > 0
        Repo.find( repos )
      else
        []
      end
    end

    def invalidate_category( name )
      id = nil
      id = Currentcategory.where( name: name ).pluck( :org_id ).first
      if id
        Invalidcategory.create( org_id: id , count_id: @count.id )
        unregister_categoryhier( name )
      end
      id
    end
    
    def ensure_invalid
      invalid_ids = Currentrepo.pluck(:org_id) - @tsg.repo.ids
      invalid_ids.map{|x|
        Invalidrepo.create( org_id: x , count_id: @count.id )
      }

      invalid_ids = Currentcategory.pluck(:org_id) - @tsg.category.ids
      invalid_ids.map{|x|
        Invalidcategory.create( org_id: x , count_id: @count.id )
        unregister_category( Category.find( x ).hier )
      }
    end

    def show_all_repo
      Currentrepo.all.each do |x|
        puts %Q!#{sprintf("% 4d" , x.id)}|#{x.repo.category.name}|#{x.desc}|#{x.path}|#{x.mtime}|#{x.ctime}!
      end
    end

    private

    def get_lines
      # 期待した通りに動かない
      ary = []
      io = IO.popen( %q!es -w -r "\.git$"!, "r")
      while l=io.gets
        ary << l.strip
      end
      ary
    end
    
    def make_group_criteria( hs_base , db_hs )
      keys_in_db_only = db_hs.keys - hs_base.keys

      hs1 = hs_base.reduce({}){ |hsx,x|
        hsx.update( x[0] => Regexp.new( Regexp.escape( x[1] ) ) )
      }
      hs2 = keys_in_db_only.reduce({}){ |hsx,k|
        hsx.update( k =>  Regexp.new( Regexp.escape( db_hs[k].path ) ) )
      }
      keys_in_hs_only = hs_base.keys - db_hs.keys
      keys_in_hs_only.map{ |x|
        v = hs_base[x]
        register_category( x.to_s , v , x.to_s )
      }
      hs1.merge( hs2 )
    end
    
    def grouping( data , group_criteria_re )
      data.group_by{ |x|
        obj = group_criteria_re.find{ |c|
          begin
            c[1].match(x)
          rescue => ex
            puts ex.message
            puts "c[1].encoding=#{c[1].encoding}"
            puts "x.encoding=#{x.encoding}"
            exit
          end
        }
        ret = obj ? obj[0] : nil
        ret
      }
    end

    def register_category( category_name , path , hier )
      category_id = nil
      current_category = Currentcategory.find_by( name: category_name )
      if current_category == nil 
        hs = { name: category_name , path: path , hier: hier }
        begin
          category = Category.create( hs )
          category_id = category.id
        rescue => ex
          p "In register_category"
          p ex.class
          p ex.message
          pp ex.backtrace
          exit

          category_id = nil
        end
      else
        category_id = current_category.category.id
        hs = {}
        if current_category.category.path != path
          hs[:path] = path
        end
        if current_category.category.hier != hier
          hs[:hier] = hier
        end
        if hs.size > 0
          current_category.category.update(  hs )
        end
      end
      if category_id
        @tsg.category.add( category_id )
      end
      category_id
    end

    def ensure_categoryhier
      Category.pluck(:hier).map{|x|
        register_categoryhier( x )
      }
    end
    
    def delete_keys( hs , keys )
      keys.map{ |key| 
        hs.delete(key)
      }
    end
    
    def register_repo_without_desc( category_id , path , mtime, ctime )
      repo_id = nil
      current_repo = Currentrepo.find_by( path: path )
      if current_repo == nil
        begin
          hs = { category_id: category_id , path: path , mtime: mtime , ctime: ctime }
          repo = Repo.create( hs )
          repo_id = repo.id
        rescue => ex
          p ex.class
          p ex.message
          pp ex.backtrace
          repo_id = nil
          exit
        end
      else
        repo_id = current_repo.repo.id
        if category_id != current_repo.repo.category_id
          update_integer( current_repo.repo, { :category_id => category_id } )
        end
      end
      
      if repo_id
        @tsg.repo.add( repo_id )
      end
      
      repo_id
    end

    def ensure_categoryhier
      Category.pluck(:name).map{|x|
        register_categoryhier( x )
      }
    end
  end
end
