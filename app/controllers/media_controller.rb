# Frozen thumbnails for voting: stream the blob directly with no redirect and
# no cache. Safari caches Active Storage 302s separately from the file and
# then paints broken "?" images on later visits (including Back).
class MediaController < ActionController::Base
  def show
    blob = ActiveStorage::Blob.find_signed!(params[:signed_id])

    send_data blob.download,
      type: blob.content_type.presence || "application/octet-stream",
      disposition: "inline",
      filename: blob.filename.to_s

    # Safari will not display <img> when Content-Disposition includes
    # filename*=; keep a plain inline header. Also disable caching so a
    # previous empty response cannot be reused.
    response.headers["Content-Disposition"] = "inline"
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    head :not_found
  end
end
