module Everythingop
module Dbutil
  class Count < ActiveRecord::Base
    has_many :invalidrepos
    has_many :invalidcategories
    has_many :invalidcategoryhiers
    has_many :invalidhier1items
    has_many :invalidhier2items
    has_many :invalidhier3items
  end

  class Countdatetime < ActiveRecord::Base
  end

  class Repo < ActiveRecord::Base
  end

  class Invalidrepo < ActiveRecord::Base
    belongs_to :repo, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currentrepo < ActiveRecord::Base
    belongs_to :repo, foreign_key: 'org_id'
  end

  class Category < ActiveRecord::Base
  end

  class Invalidcategory < ActiveRecord::Base
    belongs_to :category, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currentcategory < ActiveRecord::Base
    belongs_to :category, foreign_key: 'org_id'
  end

  class Categoryhier < ActiveRecord::Base
  end

  class Invalidcategoryhier < ActiveRecord::Base
    belongs_to :categoryhier, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currentcategoryhier < ActiveRecord::Base
    belongs_to :categoryhier, foreign_key: 'org_id'
  end

  class L1 < ActiveRecord::Base
  end

  class L2 < ActiveRecord::Base
  end

  class L3 < ActiveRecord::Base
  end

  class Criteria < ActiveRecord::Base
  end

  class Hier1 < ActiveRecord::Base
  end

  class Hier2 < ActiveRecord::Base
  end

  class Hier3 < ActiveRecord::Base
  end

  class Hier1item < ActiveRecord::Base
  end

  class Invalidhier1item < ActiveRecord::Base
    belongs_to :hier1item, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currenthier1item < ActiveRecord::Base
    belongs_to :hier1item, foreign_key: 'org_id'
  end

  class Hier2item < ActiveRecord::Base
  end

  class Invalidhier2item < ActiveRecord::Base
    belongs_to :hier2item, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currenthier2item < ActiveRecord::Base
    belongs_to :hier2item, foreign_key: 'org_id'
  end

  class Hier3item < ActiveRecord::Base
  end

  class Invalidhier3item < ActiveRecord::Base
    belongs_to :hier3item, foreign_key: 'org_id'
    belongs_to :count, foreign_key: ''
  end

  class Currenthier3item < ActiveRecord::Base
    belongs_to :hier3item, foreign_key: 'org_id'
  end
end
end
