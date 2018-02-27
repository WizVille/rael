require "active_record"
require "globalize"

class Question < ActiveRecord::Base
  belongs_to :questionnaire_page

  translates :content
  attribute :content
end
