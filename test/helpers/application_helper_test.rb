require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  class UrlThumbnail
    def initialize(url)
      @url = url
    end

    def thumbnail
      @thumbnail ||= Thumbnail.new
    end

    def thumbnail_url
      @url
    end

    class Thumbnail
      def attached?
        false
      end
    end
  end

  test "pins external thumbnail URLs inside the aspect-ratio box for Safari" do
    html = thumbnail_image_tag(UrlThumbnail.new("https://img.youtube.com/vi/abc/maxresdefault.jpg"))

    assert_includes html, "absolute inset-0"
    assert_includes html, "h-full w-full object-cover"
    assert_includes html, 'loading="eager"'
    assert_includes html, 'referrerpolicy="no-referrer"'
    assert_includes html, "https://img.youtube.com/vi/abc/maxresdefault.jpg"
    assert_not_includes html, 'loading="lazy"'
  end
end
