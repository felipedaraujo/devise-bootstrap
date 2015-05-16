class Metric < ActiveRecord::Base
  belongs_to :protocol, :dependent => :destroy
end
