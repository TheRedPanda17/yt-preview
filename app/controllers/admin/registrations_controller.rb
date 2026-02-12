module Admin
  class RegistrationsController < ApplicationController
    layout "admin"

    def new
      @admin = AdminUser.new
    end

    def create
      @admin = AdminUser.new(admin_params)
      if @admin.save
        session[:admin_id] = @admin.id
        redirect_to admin_videos_path, notice: "Account created successfully!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def admin_params
      params.require(:admin_user).permit(:email, :password, :password_confirmation, :yt_username, :yt_profile_picture_url)
    end
  end
end
