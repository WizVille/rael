require "active_record"
require "globalize"

class Preference < ActiveRecord::Base
  belongs_to :questionnaire_page
  belongs_to :first_question, :class_name => "Question"

  serialize :custom_options, HashWithIndifferentAccess

  has_one :account
end
