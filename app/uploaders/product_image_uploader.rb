# encoding: utf-8

class ProductImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  process :fix_exif_rotation_and_strip_exif

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :resize_to_fit => [160, 160]
  end

  version :view do
    process :resize_to_fit => [640, 480]
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def fix_exif_rotation_and_strip_exif
    manipulate! do |img|
      img = img.auto_orient
      img.strip!
      img = yield(img) if block_given?
      img
    end
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
     var = :"@#{mounted_as}_secure_token"
     model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
