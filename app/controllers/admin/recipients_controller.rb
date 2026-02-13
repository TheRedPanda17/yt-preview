module Admin
  class RecipientsController < BaseController
    def index
      @recipients = current_admin.recipients.order(:name)
    end

    def create
      @recipient = current_admin.recipients.build(recipient_params)
      if @recipient.save
        redirect_to admin_recipients_path, notice: "#{@recipient.name} added!"
      else
        @recipients = current_admin.recipients.order(:name)
        flash.now[:alert] = @recipient.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @recipient = current_admin.recipients.find(params[:id])
      name = @recipient.name
      @recipient.destroy
      redirect_to admin_recipients_path, notice: "#{name} removed."
    end

    private

    def recipient_params
      params.require(:recipient).permit(:name)
    end
  end
end
