class YoutubeDetailsRetriver
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
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=#{video_id}&fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&key=AIzaSyCsPFXcf-YxkgOCnKr7N227Q389kCBRS_I"
    video_data = JSON.load(open(url))
    raise StandardError.new("Youtube video not found!") if video_data["items"].blank?
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
end
