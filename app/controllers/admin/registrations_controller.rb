module Admin
  class RegistrationsController < ApplicationController
    layout "admin"

    def new
      @admin = AdminUser.new
    end

    def create
      unless ENV["ADMIN_INVITE_CODE"].present?
        @admin = AdminUser.new(admin_params)
        @admin.errors.add(:base, "Signups are currently disabled. No invite code has been configured.")
        render :new, status: :unprocessable_entity
        return
      end

      if params[:invite_code].blank? || params[:invite_code] != ENV["ADMIN_INVITE_CODE"]
        @admin = AdminUser.new(admin_params)
        @admin.errors.add(:base, "Invalid invite code.")
        render :new, status: :unprocessable_entity
        return
      end

      @admin = AdminUser.new(admin_params)
      if @admin.save
        reset_session
        session[:admin_id] = @admin.id
        redirect_to admin_videos_path, notice: "Account created successfully!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def admin_params
      params.require(:admin_user).permit(:email, :password, :password_confirmation, :yt_username, :yt_profile_picture_url, :profile_picture)
    end
  end
end
