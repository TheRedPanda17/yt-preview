require "test_helper"

class MediaControllerTest < ActionDispatch::IntegrationTest
  test "streams the blob inline without caching" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("fake-jpeg-bytes"),
      filename: "thumb.jpg",
      content_type: "image/jpeg"
    )

    get media_url(blob.signed_id)

    assert_response :success
    assert_equal "fake-jpeg-bytes", response.body
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal "inline", response.headers["Content-Disposition"]
    assert_includes response.media_type, "jpeg"
  end

  test "returns not found for an invalid signed id" do
    get media_url("not-a-real-signed-id")

    assert_response :not_found
  end
end
