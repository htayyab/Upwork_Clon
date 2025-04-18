class AttachmentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads"
  end

  def extension_allowlist
    %w[pdf doc docx jpg jpeg png]
  end

  def filename
    "#{Time.current.to_i}_#{original_filename}" if original_filename.present?
  end
end
