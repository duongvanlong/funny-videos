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
    video = Video.where(video_id: video_id, user_id: current_user.id).first_or_initialize
    if video.new_record?
      flash[:notice] = "Video successfully created"
    else
      flash[:notice] = "Video existed already"
    end
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{video_id}&fields=items/snippet/title,items/snippet/description&key=AIzaSyCsPFXcf-YxkgOCnKr7N227Q389kCBRS_I"
    video_data = JSON.load(open(url))
    video.title = video_data["items"].first["snippet"]["title"]
    video.description = video_data["items"].first["snippet"]["description"]
    video.save!
    redirect_to root_path
  end

  private
  def get_youtube_id(url)
  id = ''
  url = url.gsub(/(>|<)/i,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
  if url[2] != nil
    id = url[2].split(/[^0-9a-z_\-]/i)
    id = id[0];
  else
    id = url;
  end
  id
end
end
