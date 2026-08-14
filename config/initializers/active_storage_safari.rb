# Safari caches Active Storage redirect responses separately from the disk
# blob. When the blob is evicted first, <img> tags paint as broken "?" icons
# until the redirect max-age expires or the cache is cleared. Align the disk
# response lifetime with the redirect lifetime for any remaining redirect URLs
# (e.g. explicit rails_blob_path helpers).
module ActiveStorageDiskControllerCacheLifetime
  private

  def serve_file(...)
    expires_in ActiveStorage.service_urls_expire_in, must_revalidate: true
    super(...)
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::DiskController.prepend ActiveStorageDiskControllerCacheLifetime
end
