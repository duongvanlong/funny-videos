class VideosController < ApplicationController
  require 'open-uri'
  def index
    @videos = Video.where(user_id: current_user.id).order("created_at desc")
  end

  def new
    @video = Video.new
  end

  def create
    video_id = get_youtube_id(params[:youtubeUrl])
    if video_id.blank?
      flash[:alert] = "Can't recognize youtube video"
      new
    else
      video = Video.where(video_id: video_id, user_id: current_user.id).first_or_initialize
      video_details = get_video_details(video_id)
      video.title = video_details[:title]
      video.description = video_details[:description]
      video.publisher = video_details[:publisher]
      video.votes_up = video_details[:likeCount]
      video.votes_down = video_details[:dislikeCount]
      video.views_count = video_details[:viewCount]
      if video.new_record?
        flash[:notice] = "Video successfully created"
      else
        flash[:notice] = "Video existed already"
      end
      video.save!
      redirect_to root_path
    end
  rescue => e
    flash[:alert] = e.message
    new
  end

  private
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
    result[:viewCount] = video_details["statistics"]["viewCount"]
    result[:likeCount] = video_details["statistics"]["likeCount"]
    result[:dislikeCount] = video_details["statistics"]["dislikeCount"]
    result
  end
end
