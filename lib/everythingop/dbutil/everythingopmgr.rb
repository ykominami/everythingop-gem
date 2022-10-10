require 'active_record'
require 'forwardable'
require 'encx'
# require 'flist/dbutil/flistzmgr'
# require 'flist/dbutil/dirzmgr'

module Everythingop
  module Dbutil
    class EverythingopMgr
      attr_reader :ct

      extend Forwardable

      def_delegator(:@dirzmgr, :add, :dirz_add)
      def_delegator(:@dirzmgr, :post_process, :dirz_post_process)
      def_delegator(:@flistzmgr, :add, :flistz_add)
      def_delegator(:@flistzmgr, :post_process, :flistz_post_process)

      def initialize(register_time)
        # DB接続タイムスタンプ
        @register_time = register_time
        # Flistを実行した回数とその時のDB接続タイムスタンプをDBに登録
        @ct = Dbutil::Countdatetime.create(countdatetime: @register_time)

        @db_encoding = Encoding::UTF_8
        @encx = Encx::Encx.init(@db_encoding)
        # @flistzmgr = FlistzMgr.new(@encx, @db_encoding, @register_time)
        # @dirzmgr = DirzMgr.new(@encx, @db_encoding, @register_time)
      end
    end
  end
end
