# -*- coding: utf-8 -*-
require 'active_record'
require 'forwardable'
require 'pp'
require 'everythingop/dbutil/everythingop_ac'
require 'arxutils'

module Everythingop
  module Dbutil
    class Count 
      has_and_belongs_to_many :repos
      has_and_belongs_to_many :categories
      has_and_belongs_to_many :currentrepos
      has_and_belongs_to_many :currentcategories
      has_many :invalidrepos
      has_many :invalidcategories
    end

    class Repo
      has_and_belongs_to_many :Counts
      belongs_to :categories , foreign_key: 'category_id'
      belongs_to :counts , foreign_key: 'count_id'      
    end

    class Invalidrepo
      belongs_to :repos , foreign_key: 'org_id'      
      belongs_to :counts , foreign_key: 'count_id'      
    end

    class Currentrepo < ActiveRecord::Base
      has_and_belongs_to_many :Counts
      belongs_to :counts , foreign_key: 'count_id'      
      belongs_to :repos , foreign_key: 'org_id'
    end
    
    class Category
      has_and_belongs_to_many :Counts
      has_many :repos
    end
    
    class Invalidcategory
      belongs_to :categories , foreign_key: 'org_id'      
      belongs_to :counts , foreign_key: 'count_id'      
    end

    class Currentcategory
      belongs_to :counts , foreign_key: 'count_id'      
      belongs_to :categories , foreign_key: 'org_id'
    end

    class Desc
      belongs_to :repos , foreign_key: 'repo_id'
    end

    class EverythingopMgr
      extend Forwardable

      def initialize(register_time)
        @register_time = register_time
        @count = Count.create( countdatetime: @register_time )
        @category_hs = {}
        @repo_hs = {}
        @repo_by_categoryname = {}

        @valid_repoinfo = Set.new
        @valid_categoryinfo = Set.new
      end
      
      def ensure_invalid
        invalid_ids = Currentrepo.pluck(:org_id) - @valid_repoinfo.to_a
        Invalidrepo.where( id: invalid_ids ).update_all( end_count_id: @count.id )

        invalid_ids = Currentcategory.pluck(:org_id) - @valid_categoryinfo.to_a
        Invalidcategory.where( id: invalid_ids ).update_all( end_count_id: @count.id )
      end
      
      def restore_category
        hs = {}
        puts "* restore_category S"
        categories = Currentcategory.all
        categories.map{ |category|
          puts category.parent_id
          @category_hs[category.name] = category
          hs[category.parent_id] ||= {}
          hs[category.parent_id][category.name] = category
        }
        puts "* restore_category E"
        hs
      end
      
      def add_category( category_name , parent_id , path )
        if (category = @category_hs[category_name] ) != nil
          category_id = category.id
        else
          cur_category = Currentcategory.where( name: category_name ).limit(1)
          if cur_category.size == 0
            begin
              category = Category.create( name: category_name , parent_id: parent_id, path: path )
              @category_hs[category_name] = category
              category_id = category.id
            rescue => ex
              p ex.class
              p ex.message
              pp ex.backtrace

              category = nil
              categorycount = nil
            end
          else
            cur_category = cur_category.first
            category_id = cur_category['org_id']
            category = Category.find( category_id )
#            Arxutils.update_integer( category , hs ) if hs.size > 0
          end
        end
        @valid_categoryinfo << category_id
        
        category_id
      end

      def add( category_name , path , mtime, ctime )
        category_id = add_category( category_name )
        @repo_hs[category_id] ||= {}
        
        hs = {:category_id => category_id, :path => path , :mtime => mtime , :ctime => ctime }
        if ( repo = @repo_hs[category_id][path] )
            Arxutils.update_integer( repo , hs )
        else
          cur_repo = Currentrepo.where( category_id: category_id , pat: path ).limit(1)
          if cur_repo.size == 0
            begin
              repo = Repo.create( category_id: category_id, path: path , mtime: mtime , ctime: ctime )
              @repo_hs[category_id][path] = repo
            rescue => ex
              p ex.class
              p ex.message
              pp ex.backtrace

              repo = nil
              repocount = nil
            end
          else
            repo = cur_repo.first
            Arxutils.update_integer( repo , hs )
          end
        end
      end
      
      def add_desc( repo_id , desc )
        if ( repo_desc = @desc_hs[repo_id] )
          if repo_desc.desc ==  desc
            #
          else
            repo_desc.update( desc: desc )
          end
        else
          repo_desc_ary = Desc.where( repo_id: repo_id ).limit(1)
          if repo_desc_ary.size == 0
            begin
              repo_desc = Desc.create( repo_id: repo_id, desc: desc )
              @desc_hs[repo_id] = repo_desc
            rescue => ex
              p ex.class
              p ex.message
              pp ex.backtrace

              repo_desc = nil
            end
          else
            repo_desc = repo_desc_ary.first
            repo_desc.update( desc: desc )
            @desc_hs[repo_id] = repo_desc
          end
        end
        
        repo_desc
      end
      
    end
  end
end
