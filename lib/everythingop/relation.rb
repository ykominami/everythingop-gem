module Everythingop
  class Count < ActiveRecord::Base
    has_many :invalidrepos
    has_many :invalidcategories
    has_many :invalidhier1items
    has_many :invalidhier2items
    has_many :invalidhier3items
  end
  

  class Repo < ActiveRecord::Base
    belongs_to :category , foreign_key: 'category_id'
    belongs_to :hier1item , foreign_key: 'hier1item_id'
    belongs_to :hier2item , foreign_key: 'hier2item_id'
    belongs_to :hier3item , foreign_key: 'hier3item_id'
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
    belongs_to :parent , class_name: 'Category' , foreign_key: 'parent_id'
    belongs_to :child  , class_name: 'Category' , foreign_key: 'child_id'
  end

  class Criteria < ActiveRecord::Base
  end

  class Hier1item < ActiveRecord::Base
    has_many :repos
  end

  class Invalidhier1item < ActiveRecord::Base
    belongs_to :hier1item , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currenthier1item < ActiveRecord::Base
    belongs_to :hier1item , foreign_key: 'org_id'
  end  

  class Hier2item < ActiveRecord::Base
    has_many :repos
  end

  class Invalidhier2item < ActiveRecord::Base
    belongs_to :hier2item , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currenthier2item < ActiveRecord::Base
    belongs_to :hier2item , foreign_key: 'org_id'
  end  

  class Hier3item < ActiveRecord::Base
    has_many :repos
  end

  class Invalidhier3item < ActiveRecord::Base
    belongs_to :hier3item , foreign_key: 'org_id'
    belongs_to :count , foreign_key: 'end_count_id'
  end  

  class Currenthier3item < ActiveRecord::Base
    belongs_to :hier3item , foreign_key: 'org_id'
  end  

  class Hier1 < ActiveRecord::Base
    belongs_to :parent , class_name: 'Hier1item' , foreign_key: 'parent_id'
    belongs_to :child  , class_name: 'Hier1item' , foreign_key: 'child_id'
  end

  class Hier2 < ActiveRecord::Base
    belongs_to :parent , class_name: 'Hier2item' , foreign_key: 'parent_id'
    belongs_to :child  , class_name: 'Hier2item' , foreign_key: 'child_id'
  end

  class Hier3 < ActiveRecord::Base
    belongs_to :parent , class_name: 'Hier3item' , foreign_key: 'parent_id'
    belongs_to :child  , class_name: 'Hier3item' , foreign_key: 'child_id'
  end

end
