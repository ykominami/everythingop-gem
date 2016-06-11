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
    has_one :categoryhiers, foreign_key: 'child_id'
    has_many :child_categories, through: :categoryhiers, source:  :child
    has_one  :parent_category,  through: :categoryhiers, source:  :parent
  end

  class Invalidcategory < ActiveRecord::Base
    belongs_to :category , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currentcategory < ActiveRecord::Base
    belongs_to :category , foreign_key: 'org_id'
  end  

  class Categoryhier < ActiveRecord::Base
    belongs_to :parent , class_name: 'Category' , foreign_key: 'parent_id'
    belongs_to :child  , class_name: 'Category' , foreign_key: 'child_id'
  end

  class Criteria < ActiveRecord::Base
  end

end
