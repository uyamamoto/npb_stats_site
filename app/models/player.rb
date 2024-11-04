class Player < ApplicationRecord
  has_one :pitching_stat
  has_one :batting_stat

  
end
