require_relative '../lib/dbacrecord'

# テスト用クラス
class Dbsetup
  def initialize(connect_time)
    @connect_time = connect_time
    @ct = Everythingop::Dbutil::Countdatetime.create(countdatetime: @connect_time)
    @hs_by_notebook = {}
    @hs_by_id = {}
  end
end
