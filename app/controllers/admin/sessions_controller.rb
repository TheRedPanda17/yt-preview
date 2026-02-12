module Admin
  class SessionsController < ApplicationController
    layout "admin"

    def new
    end

    def create
      admin = AdminUser.find_by(email: params[:email])
      if admin&.authenticate(params[:password])
        reset_session
        session[:admin_id] = admin.id
        redirect_to admin_videos_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:admin_id)
      redirect_to root_path, notice: "Logged out."
    end
  end
end
