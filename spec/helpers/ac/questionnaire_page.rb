require "active_record"
require "globalize"

class QuestionnairePage < ActiveRecord::Base
  has_many :questions
  has_one  :preference

  translates :title, :subtitle
  attribute :title
  attribute :subtitle
end
