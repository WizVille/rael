require "active_record"
require "globalize"

class Question < ActiveRecord::Base
  belongs_to :questionnaire_page

  has_one :question_preference

  translates :content
  attribute :content
end
