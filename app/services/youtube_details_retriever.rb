class YoutubeDetailsRetriever
  require 'open-uri'
  VIDEO_RETRIEVE_FIELDS= [
    "items/snippet/title",
    "items/snippet/description",
    "items/snippet/channelTitle",
    "items/statistics/viewCount",
    "items/statistics/likeCount",
    "items/statistics/dislikeCount"
  ].freeze

  class VideoNotFound < StandardError
    def message
      "Youtube video not found!"
    end
  end

  class InvalidRespond < StandardError; end

  def get_youtube_id(url)
    id = ''
    url = url.gsub(/(>|<)/i,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
    if url[2] != nil
      id = url[2].split(/[^0-9a-z_\-]/i)
      id = id[0];
    end
    id
  end

  def get_video_details(video_id)
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=#{video_id}&fields=#{retrieve_fields}&key=#{ENV["GOOGLE_API_KEY"]}"
    video_data = JSON.load(open(url))
    raise VideoNotFound if video_data["items"].blank?
    raise InvalidRespond unless video_data.keys.include? "items"
    result = {}
    video_details = video_data["items"].first
    result[:title] = video_details["snippet"]["title"]
    result[:description] = video_details["snippet"]["description"]
    result[:publisher] = video_details["snippet"]["channelTitle"]
    result[:views_count] = video_details["statistics"]["viewCount"]
    result[:votes_up] = video_details["statistics"]["likeCount"]
    result[:votes_down] = video_details["statistics"]["dislikeCount"]
    result
  end

  private
  def retrieve_fields
    VIDEO_RETRIEVE_FIELDS.join(",")
  end

end
