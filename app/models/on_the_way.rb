class On_The_Way < ActiveRecord::Base
  validates(:start_address, { :presence => true })
end
