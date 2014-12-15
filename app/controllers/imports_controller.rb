class ImportsController < ApplicationController

  layout "settings"

  def create
    @user = current_user
    @import = Import.new(import_params)
    @import.user_id = @user.id

    if @import.save
      @import.build_import_job
      redirect_to settings_import_export_url, notice: 'Import has started.'
    else
      @messages = @import.errors.full_messages
      flash[:error] = render_to_string partial: "shared/messages"
      redirect_to settings_import_export_url
    end
  rescue ActionController::ParameterMissing => e
    @messages = ['File is required']
    flash[:error] = render_to_string partial: "shared/messages"
    redirect_to settings_import_export_url
  end



  private

  def import_params
    params.require(:import).permit(:upload)
  end

end
