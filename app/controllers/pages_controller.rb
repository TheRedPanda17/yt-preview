class PagesController < ApplicationController
  def home
    if current_admin
      redirect_to admin_videos_path
    end
  end
end
