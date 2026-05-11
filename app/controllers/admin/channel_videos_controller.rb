require "net/http"

module Admin
  class ChannelVideosController < BaseController
    before_action :set_channel_video, only: [ :show, :edit, :update, :destroy ]

    def index
      @channel_videos = current_admin.channel_videos.with_attached_thumbnail
    end

    def show
      redirect_to edit_admin_channel_video_path(@channel_video)
    end

    def new
      @channel_video = current_admin.channel_videos.build
    end

    def create
      @channel_video = current_admin.channel_videos.build(channel_video_params)
      @channel_video.position = current_admin.channel_videos.count

      if @channel_video.save
        redirect_to admin_channel_videos_path, notice: "Channel video added!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def import
      youtube_url = params[:youtube_url].to_s.strip
      imported_attrs = fetch_youtube_video_attrs(youtube_url)
      channel_video = current_admin.channel_videos.build(imported_attrs)
      channel_video.position = current_admin.channel_videos.count

      if channel_video.save
        redirect_to admin_channel_videos_path, notice: "Imported channel video from YouTube!"
      else
        redirect_to admin_channel_videos_path, alert: "Could not import video: #{channel_video.errors.full_messages.join(', ')}"
      end
    rescue ArgumentError => e
      redirect_to admin_channel_videos_path, alert: e.message
    rescue StandardError
      redirect_to admin_channel_videos_path, alert: "Could not reach YouTube. Check the video URL and try again."
    end

    def edit
    end

    def update
      if @channel_video.update(channel_video_params)
        redirect_to admin_channel_videos_path, notice: "Channel video updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @channel_video.destroy
      redirect_to admin_channel_videos_path, notice: "Channel video deleted."
    end

    private

    def set_channel_video
      @channel_video = current_admin.channel_videos.find(params[:id])
    end

    def channel_video_params
      params.require(:channel_video).permit(:title, :thumbnail_url, :thumbnail, :view_count, :published_at_label, :duration, :youtube_url, :position)
    end

    def fetch_youtube_video_attrs(youtube_url)
      uri = URI.parse(youtube_url)
      raise ArgumentError, "Enter a valid YouTube video URL." unless uri.is_a?(URI::HTTP) && uri.host.present?

      fetch_youtube_oembed_attrs(youtube_url).merge(fetch_youtube_data_attrs(youtube_url))
    rescue JSON::ParserError, KeyError
      raise ArgumentError, "YouTube returned an unexpected response for that video."
    end

    def fetch_youtube_oembed_attrs(youtube_url)
      oembed_uri = URI("https://www.youtube.com/oembed")
      oembed_uri.query = URI.encode_www_form(url: youtube_url, format: "json")
      response = Net::HTTP.get_response(oembed_uri)
      raise ArgumentError, "YouTube could not import that video. Make sure the video is public." unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      {
        title: data.fetch("title"),
        thumbnail_url: data.fetch("thumbnail_url"),
        youtube_url: youtube_url
      }
    end

    def fetch_youtube_data_attrs(youtube_url)
      api_key = ENV["YOUTUBE_API_KEY"].to_s
      return {} if api_key.blank?

      video_id = youtube_video_id(youtube_url)
      return {} if video_id.blank?

      api_uri = URI("https://www.googleapis.com/youtube/v3/videos")
      api_uri.query = URI.encode_www_form(
        id: video_id,
        part: "snippet,statistics,contentDetails",
        key: api_key
      )
      response = Net::HTTP.get_response(api_uri)
      return {} unless response.is_a?(Net::HTTPSuccess)

      item = JSON.parse(response.body).fetch("items").first
      return {} unless item

      snippet = item.fetch("snippet", {})
      statistics = item.fetch("statistics", {})
      content_details = item.fetch("contentDetails", {})

      {
        title: snippet["title"],
        thumbnail_url: best_thumbnail_url(snippet["thumbnails"]),
        view_count: formatted_view_count(statistics["viewCount"]),
        published_at_label: formatted_published_at(snippet["publishedAt"]),
        duration: formatted_duration(content_details["duration"])
      }.compact
    end

    def youtube_video_id(youtube_url)
      uri = URI.parse(youtube_url)
      host = uri.host.to_s.downcase

      if host == "youtu.be"
        uri.path.delete_prefix("/").split("/").first
      elsif host.end_with?("youtube.com")
        if uri.path == "/watch"
          Rack::Utils.parse_query(uri.query)["v"]
        elsif uri.path.start_with?("/shorts/", "/embed/")
          uri.path.split("/")[2]
        end
      end
    end

    def best_thumbnail_url(thumbnails)
      return if thumbnails.blank?

      %w[maxres standard high medium default].each do |quality|
        url = thumbnails.dig(quality, "url")
        return url if url.present?
      end

      nil
    end

    def formatted_view_count(view_count)
      count = view_count.to_i
      return if count.zero?

      compact_count =
        if count >= 1_000_000_000
          "#{(count / 1_000_000_000.0).round(1)}B"
        elsif count >= 1_000_000
          "#{(count / 1_000_000.0).round(1)}M"
        elsif count >= 1_000
          "#{(count / 1_000.0).round(1)}K"
        else
          count.to_s
        end

      "#{compact_count.sub('.0', '')} views"
    end

    def formatted_published_at(published_at)
      return if published_at.blank?

      "#{view_context.time_ago_in_words(Time.zone.parse(published_at))} ago"
    end

    def formatted_duration(duration)
      return if duration.blank?

      match = duration.match(/\APT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?\z/)
      return unless match

      hours = match[1].to_i
      minutes = match[2].to_i
      seconds = match[3].to_i

      if hours.positive?
        "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
      else
        "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
      end
    end
  end
end
