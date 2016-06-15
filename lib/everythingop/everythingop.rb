# -*- coding: utf-8 -*-
require 'arxutils'
require 'forwardable'
require 'everythingop/relation'
require 'everythingop/everythingop_init'
require 'pathname'
require 'pp'
require 'csv'

module Everythingop
  class Everythingop
    extend Forwardable
    include Arxutils
    
    def_delegator( :@hierop , :register , :register_categoryhier )
    def_delegator( :@hierop , :delete   , :unregister_categoryhier )
    def_delegator( :@hierop , :move     , :move_categoryhier )

    attr_reader :group , :group_v_ext2

    def initialize( kind, hs , fname = nil)
      @hierop = HierOp.new( :hier , Category , Categoryhier, Currentcategory )
      @hieritem ||= Struct.new( "Hieritem" , :field_name, :hier_name , :base_asoc_name , :base_klass , :hier_klass, :cur_klass , :op_inst )
      @hieritem_ary = [
        @hieritem.new( "hier1item_id", :hier , "hier1item" , Hier1item , Hier1, Currenthier1item ),
        @hieritem.new( "hier2item_id", :hier , "hier2item" , Hier2item , Hier2, Currenthier2item ),
        @hieritem.new( "hier3item_id", :hier , "hier3item" , Hier3item , Hier3, Currenthier3item )
      ]
      @hieritem_ary.map{ |x| x.op_inst = HierOp.new( x.hier_name, x.base_klass , x.hier_klass, x.cur_klass ) }
      @hieritem_hs = @hieritem_ary.reduce({}){ |s,x|
      }

      @tsg = TransactStateGroup.new( :category , :repo , :hier1item, :hier2item, :hier3item )
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
      

      @repo_ary = []
      variable_init
    end

    def set_mode( mode = :MIXED_MODE )
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

    def reorder_hier
      @hieritem_ary.zip( @z_hier ).map{|x|
        hi = x[0]
        data = x[1]

        hs_count = hi.hier_klass.group(:parent_id).count(:parent_id)
        if hs_count.size == 0
          data.map{ |name|
            register_hieritem( hi , name )
          }
          hi.cur_klass.pluck(:hier).map{ |y|
            hi.op_inst.register( y )
          }
          hs_count = hi.hier_klass.group(:parent_id).count(:parent_id)
        end
        hs_count.keys.reduce({}){ |hs, x|
          hs[x] = Category.find( Categoryhier.where( parent_id: x ).pluck( :child_id ) )
          hs
        }
      }
    end
    
    def reorder_category
      hs_count = Categoryhier.group(:parent_id).count(:parent_id)

      category_hs_by_parent_id = hs_count.keys.reduce({}){ |hs, x|
        hs[x] = Category.find( Categoryhier.where( parent_id: x ).pluck( :child_id ) )
        hs
      }

      # parent_idが0のもの
      category_group_by_parent = category_hs_by_parent_id.group_by{ |x| x[0] == 1 ? :one : :not_one }

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
    
    def get_all_repo
      unless @group
        @category_exclude_ary.map{ |key| 
          @group_criteria_re.delete(key)
        }
        
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

          set_hier
        }
      end
      
      data = @group[:""]
      data = @group[nil] unless data
      if data
        @group_v_ext2 = grouping( data , @group_criteria_re_v_ext2 )
        @group_v_ext2.select{ |x| x != nil and x[0] != nil }.map{ |x|
          current_category = Currentcategory.find_by( name: x[0].to_s )
          if current_category
            x[1].each { |l|
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
            }
          end
        }
      end
    end

    def list_category
      cur = Currentcategory.where( hier: "/stack_root/1" ).first
      ch = Categoryhier.find_by( child_id: cur.category.id )
      
      Currentcategory.pluck( :name , :path , :path )
    end
    
    def list_repo_1
      get_all_repo
      
      repos = Currentrepo.pluck(:org_id)
      if repos.size > 0
        Repo.find( repos )
      else
        []
      end
    end

    def list_repo_2
      get_all_repo
      
      Currentcategory.all.map{ |x|
        category = x.category
        puts category.name
        category.repos.map{ |y| puts %Q! #{y.path}|#{y.desc}! }
      }
    end

    def list_repo
      get_all_repo
      
      Categoryhier.where( parent_id: @v_ext2_git_top_category_id ).pluck( :child_id ).map{ |x|
        category = Category.find( x )
        ary = category.repos
        if ary.size > 0
          puts %Q!#{category.name}!
          ary.map{ |y|
            puts %Q! #{y.path}|#{y.desc}!
          }
        end
      }
#      @hieritem_ary.map{ |x| list_hier( x ) }
#      list_hierx
    end

    def unset_repo_by_path_in_hier1item( src_path  )
      unset_repo_by_path_in_hieritem( 0 , src_path )
    end
    
    def unset_repo_by_path_in_hier2item( src_path  )
      unset_repo_by_path_in_hieritem( 1 , src_path )
    end
    
    def unset_repo_by_path_in_hier3item( src_path  )
      unset_repo_by_path_in_hieritem( 2 , src_path )
    end
    
    def unset_repo_by_path_in_hieritem( num , src_path )
      repo = Currentrepo.find_by( path: src_path ).repo
      unset_repo_in_hieritem( num , repo )
    end
    
    def unset_repo_in_hieritem( num , repo )
      hi_info = @hieritem_ary[num]
      if repo
        hs = { hi_info.field_name.to_sym => nil }
        repo.update( hs )
      else
        puts "Can't find #{dest_hier} in #{num}"
      end
    end
    


    def move_repo_by_path_in_hier1item_by_path( src_path , dest_hier_path )
      move_repo_by_path_in_hieritem( 0 , srcr_path , dest_hierr_path )
    end

    def move_repo_by_path_in_hier2item_by_path( srcr_path , dest_hierr_path )
      move_repo_by_path_in_hieritem( 1 , srcr_path , dest_hierr_path )
    end

    def move_repo_by_path_in_hier3item_by_path( srcr_path , dest_hierr_path )
      move_repo_by_path_in_hieritem( 2 , srcr_path , dest_hierr_path )
    end

    def move_repo_by_path_in_hieritem_by_path( num , srcr_path , dest_hierr_path )
      repo = Currentrepo.find_by( path: srcr_path ).repo
      move_repo_in_hieritem( num , repo , dest_hierr_path )
    end
    
    def move_repo_in_hieritem_by_path( num , repo , dest_hierr_path )
      puts "dest_hier=#{dest_hierr_path}"
      hi_info = @hieritem_ary[num]
      hs_target = { hi_info.hier_name => dest_hierr_path }
      hi = hi_info.cur_klass.find_by( hs_target )
      move_repo_in_hieritem( hi_info ,  repo , hi )
    end
    
    def move_repo_in_hieritem( hi_info ,  repo , hi )
      if hi
        hieritem = hi.__send__ hi_info.base_asoc_name
        hs = { hi_info.field_name.to_sym => hieritem.id }
        p hs
        repo.update( hs )
      else
        puts "Can't find #{dest_hier} in #{num}"
      end
    end
    
    def move_in_hieritem( src , dest_hier )
    end
    
    def list_hierx
      hs = Currentrepo.all.reduce({}){ |s,x|
        repo = x.repo
        @hieritem_ary.map{ |y|
          sym = y.base_asoc_name.to_sym
          s[ sym ] ||= {}
          hieritem = repo.__send__ y.base_asoc_name
          s[ sym ][ hieritem ] ||= []
          s[ sym ][ hieritem ] << repo
        }
        s
      }
      @hieritem_ary.map{ |y|
        sym = y.base_asoc_name.to_sym
        p sym
        hs[ sym ].keys.sort_by{ |a,b|
          if a != nil
            if b != nil
              a.hier <=> b.hier
            else
              1
            end
          else
            if b != nil
              -1
            else
              0
            end
          end
        }.map{ |z|
          if z
            puts z.__send__ y.hier_name
          else
            puts "nil"
          end
          hs[ sym ][ z ].map{ |a|
            puts %Q!  #{a.path}|#{a.desc}!
          }
        }
        puts ""
      }
    end
    
    def list_hier_1( hieritem )
      hieritem.cur_klass.all.order( :hier ).select{ |x|
        (x.__send__ hieritem.base_asoc_name).repos.size > 0
      }.map{ |x|
        hi = x.__send__ hieritem.base_asoc_name
        puts %Q!#{hi.hier}!
        hi.repos.map{ |y|
          puts %Q! #{y.path}|#{y.desc}!
        }
      }
      puts ""
    end

    def list_hier( hieritem )
      ary = hieritem.cur_klass.all.order( :hier ).reduce([]){ |s,x|
        hi = (x.__send__ hieritem.base_asoc_name)
        s << [ hi, hi.repos ] if hi.repos.size > 0
        s
      }
      if ary.size > 0
        puts %Q!* #{hieritem.base_asoc_name}!
        ary.map{ |x|
          hi , repos , tmp = x
          puts %Q!#{hi.hier}!
          repos.map{ |y|
            puts %Q! #{y.path}|#{y.desc}!
          }
        }
        puts ""
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

    def save_repo
      fname = "repo.tsv"
      header = ["id","category_id","desc","path","mtime","ctime","hier1item_id","hier2item_id","hier3item_id","created_at","updated_at"]
      CSV.open( fname , "w" , {:col_sep => "\t" , :headers => header} ){|csv|
        @repo_ary.map{|x| csv << x}
      }
    end
    
    def set_hier
      Currentrepo.all.reduce( 1 ){ |s,x|
        hs = { :hier1item_id => s , :hier2item_id => (s+1), :hier3item_id => (s+2) }
        p hs
        x.repo.update( hs )
        (s + 3)
      }
    end

    def reset_hieritem_in_repo
      Repo.all.map{ |x|
        hs = @hieritem_ary.reduce({}){ |s,y|
          s[ y.base_asoc_name.to_sym ] = nil
          s
        }
        x.update( hs )
      }
    end

    def get_category_hier_jsondata
      JSON( Categoryhier.pluck( :parent_id , :child_id , :level ).map{ |ary|
              text = Category.find( ary[1] ).hier.split("/").pop
              if ary[2] == 0
                parent_id = "#"
              else
                parent_id = %Q!#{ary[0]}!
              end
              child_id = %Q!#{ary[1]}!
        { "id" => child_id , "parent" => parent_id , "text" => text }
      } )
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

    def register_hieritem( hieritem, hier )
      id = nil
      hs = { hieritem.hier_name => hier }
      cur = hieritem.cur_klass.find_by( hs )
      if cur == nil 
        begin
          item = hieritem.base_klass.create( hs )
          id = item.id
        rescue => ex
          p "In register_hier"
          p ex.class
          p ex.message
          pp ex.backtrace
          exit

          id = nil
        end
      else
        met = hieritem.base_asoc_name
        id = (cur.__send__ met).id
      end
      if id
        met = hieritem.base_asoc_name
        (@tsg.__send__  met).add( id )
      end
      id
    end

    def ensure_categoryhier
      Category.pluck(:hier).map{|x|
        register_categoryhier( x )
      }
    end

    def register_repo_without_desc( category_id , path , mtime, ctime )
      repo_id = nil
      current_repo = Currentrepo.find_by( path: path )
      if current_repo == nil
        begin
          hs = { category_id: category_id , path: path , mtime: mtime , ctime: ctime }
          # ["id","category_id","desc","path","mtime","ctime","hier1item_id","hier2item_id","hier3item_id","created_at","updated_at"]
          repo_id = @repo_ary.size + 1
          time="2016-06-12 03:55:47"
          @repo_ary << [repo_id , category_id , path, mtime, ctime, nil, nil, nil, time, time]
#          repo = Repo.create( hs )
#          repo_id = repo.id
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
