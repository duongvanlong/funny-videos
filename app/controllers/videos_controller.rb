class VideosController < ApplicationController
  def index
    page = params[:page] || 1
    @videos = Video.where(user_id: current_user.id).page(page).order("created_at desc")
  end

  def new
    @video = Video.new
  end

  def create
    video_id = youtube_service.get_youtube_id(params[:youtubeUrl])
    if video_id.blank?
      flash[:alert] = "Can't recognize youtube video"
      redirect_to action: 'new', youtubeUrl: params[:youtubeUrl]
    else
      video = Video.where(video_id: video_id, user_id: current_user.id).first_or_initialize
      video_details = youtube_service.get_video_details(video_id)

      video.assign_attributes video_details
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
    redirect_to action: 'new', youtubeUrl: params[:youtubeUrl]
  end

  private
  def youtube_service
    @youtube_service ||= ::YoutubeDetailsRetriever.new
  end
end
