module ApplicationHelper
  THUMBNAIL_IMG_CLASSES = "absolute inset-0 h-full w-full object-cover"

  # Safari does not resolve percentage heights on <img> inside aspect-ratio
  # boxes, so thumbnails collapse to 0px and never paint. Pin the image to the
  # frame instead. Do not use loading="lazy": Safari often leaves those images
  # as broken "?" icons until a full refresh, especially after Turbo visits.
  # External URLs omit the referrer so hotlinked thumbnails are not blocked.
  def thumbnail_image_tag(record, **html_options)
    classes = [ THUMBNAIL_IMG_CLASSES, html_options.delete(:class) ].compact.join(" ")
    html_options = { alt: "", class: classes, loading: "eager" }.merge(html_options)

    if record.thumbnail.attached?
      image_tag(record.thumbnail, html_options)
    elsif record.respond_to?(:thumbnail_url) && record.thumbnail_url.present?
      image_tag(record.thumbnail_url, html_options.merge(referrerpolicy: "no-referrer"))
    end
  end
end
