# Safari caches Active Storage 302 redirects separately from the file. When
# the file is evicted first, <img> tags paint as broken "?" icons. Never let
# Safari store those responses.
module ActiveStorageSafariNoStore
  def show
    response.headers["Cache-Control"] = "no-store"
    super
  end
end

module ActiveStorageDiskSafariNoStore
  private

  def serve_file(...)
    response.headers["Cache-Control"] = "no-store"
    super(...)
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Blobs::RedirectController.prepend ActiveStorageSafariNoStore
  ActiveStorage::Blobs::ProxyController.prepend ActiveStorageSafariNoStore
  ActiveStorage::DiskController.prepend ActiveStorageDiskSafariNoStore
end
