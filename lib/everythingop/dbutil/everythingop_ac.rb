# -*- coding: utf-8 -*-
require 'active_record'
require 'forwardable'
require 'pp'

module Everythingop
  module Dbutil
    class Count < ActiveRecord::Base
    end
    
    class Repo < ActiveRecord::Base
    end
    
    class Invalidrepo < ActiveRecord::Base
    end
    
    class Currentrepo < ActiveRecord::Base
    end
    
    class Desc < ActiveRecord::Base
    end
    
    class Category < ActiveRecord::Base
    end
    
    class Invalidcategory < ActiveRecord::Base
    end

    class Currentcategory < ActiveRecord::Base
    end
  end
end
