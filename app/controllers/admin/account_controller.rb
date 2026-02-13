module Admin
  class AccountController < BaseController
    def edit
      @admin = current_admin
    end

    def update
      @admin = current_admin
      if @admin.update(account_params)
        redirect_to admin_account_path, notice: "Account updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def account_params
      params.require(:admin_user).permit(:yt_username, :yt_profile_picture_url, :profile_picture)
    end
  end
end
