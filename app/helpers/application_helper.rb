module ApplicationHelper
  THUMBNAIL_IMG_CLASSES = "absolute inset-0 h-full w-full object-cover"

  # Safari breaks Active Storage redirect URLs (cached 302 → empty blob → "?").
  # Prefer the storage proxy path so the image is streamed without a redirect.
  # Pin the image inside aspect-ratio frames, omit the referrer on hotlinked
  # external thumbnails, and uniquify srcs per step/record so Safari does not
  # reuse a broken in-memory image from a previous voting step.
  def thumbnail_image_tag(record, **html_options)
    classes = [ THUMBNAIL_IMG_CLASSES, html_options.delete(:class) ].compact.join(" ")
    html_options = { alt: "", class: classes, loading: "eager" }.merge(html_options)

    src = thumbnail_src(record)
    return if src.blank?

    src = uniquify_thumbnail_src(src, record)
    options = html_options
    options = options.merge(referrerpolicy: "no-referrer") unless record.thumbnail.attached?
    image_tag(src, options)
  end

  private

  def thumbnail_src(record)
    if record.thumbnail.attached?
      rails_storage_proxy_path(record.thumbnail)
    elsif record.respond_to?(:thumbnail_url) && record.thumbnail_url.present?
      record.thumbnail_url
    end
  end

  def uniquify_thumbnail_src(src, record)
    token = [ params[:step], params[:vi], params[:ci], record.try(:id) ].compact.join("-")
    return src if token.blank?

    joiner = src.include?("?") ? "&" : "?"
    "#{src}#{joiner}d=#{ERB::Util.url_encode(token)}"
  end
end
