require 'date_flag'

ActiveRecord::Base.send(:extend, DateFlag)
