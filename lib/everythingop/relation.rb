module Everythingop
  class Count < ActiveRecord::Base
    has_many :invalidrepos
    has_many :invalidcategories
  end
  

  class Repo < ActiveRecord::Base
    belongs_to :category , foreign_key: 'category_id'
  end

  class Invalidrepo < ActiveRecord::Base
    belongs_to :repo , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currentrepo < ActiveRecord::Base
    belongs_to :repo , foreign_key: 'org_id'
  end  

  class Category < ActiveRecord::Base
    has_many :repos
  end

  class Invalidcategory < ActiveRecord::Base
    belongs_to :category , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currentcategory < ActiveRecord::Base
    belongs_to :category , foreign_key: 'org_id'
  end  

  class Categoryhier < ActiveRecord::Base
    belongs_to :category , foreign_key: 'parent_id'
    belongs_to :category , foreign_key: 'child_id'
  end

  class Management < ActiveRecord::Base
  end

  class Criteria < ActiveRecord::Base
  end

end
