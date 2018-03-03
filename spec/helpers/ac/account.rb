require "active_record"
require "globalize"
require 'carrierwave'
require 'carrierwave/orm/activerecord'

require_relative "./test_uploader"

class Account < ActiveRecord::Base
  belongs_to :preference
  after_save :check_unique_id

  mount_uploader :avatar, TestUploader

  def check_unique_id
    raise "check_unique_id" if Account.where(:unique_id => self.unique_id).count == 2
  end
end
