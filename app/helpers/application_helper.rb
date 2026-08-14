module ApplicationHelper
  THUMBNAIL_IMG_CLASSES = "absolute inset-0 h-full w-full object-cover"

  # Safari mis-caches Active Storage redirect/proxy URLs and paints broken "?"
  # icons. Serve uploads from /media/:signed_id (inline, no-store, no redirect)
  # and omit the referrer on hotlinked external thumbnails.
  def thumbnail_image_tag(record, **html_options)
    classes = [ THUMBNAIL_IMG_CLASSES, html_options.delete(:class) ].compact.join(" ")
    html_options = { alt: "", class: classes }.merge(html_options)

    if record.thumbnail.attached?
      image_tag(media_path(record.thumbnail.blob.signed_id), html_options)
    elsif record.respond_to?(:thumbnail_url) && record.thumbnail_url.present?
      image_tag(record.thumbnail_url, html_options.merge(referrerpolicy: "no-referrer"))
    end
  end
end
