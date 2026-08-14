module ApplicationHelper
  THUMBNAIL_IMG_CLASSES = "absolute inset-0 h-full w-full object-cover"

  # Safari breaks Active Storage redirect URLs (cached 302 → empty blob → "?").
  # Prefer the storage proxy path so the image is streamed without a redirect.
  # Pin the image inside aspect-ratio frames, and omit the referrer on hotlinked
  # external thumbnails so CDNs do not block them.
  def thumbnail_image_tag(record, **html_options)
    classes = [ THUMBNAIL_IMG_CLASSES, html_options.delete(:class) ].compact.join(" ")
    html_options = { alt: "", class: classes, loading: "eager" }.merge(html_options)

    if record.thumbnail.attached?
      image_tag(rails_storage_proxy_path(record.thumbnail), html_options)
    elsif record.respond_to?(:thumbnail_url) && record.thumbnail_url.present?
      image_tag(record.thumbnail_url, html_options.merge(referrerpolicy: "no-referrer"))
    end
  end
end
