class VideosController < ApplicationController
  def index
  end

  def new
    @video = Video.new
  end
end
