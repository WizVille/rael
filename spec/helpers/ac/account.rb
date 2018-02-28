require "active_record"
require "globalize"

class Account < ActiveRecord::Base
  belongs_to :preference

  validates :unique_id, uniqueness: { case_sensitive: false }
end
