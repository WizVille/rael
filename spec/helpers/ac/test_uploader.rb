require 'carrierwave'

class TestUploader < CarrierWave::Uploader::Base
  storage :file
end
