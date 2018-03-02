require "active_record"
require "globalize"

class QuestionPreference < ActiveRecord::Base
  belongs_to :question
end
