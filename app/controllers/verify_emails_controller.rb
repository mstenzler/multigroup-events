class VerifyEmailsController < ApplicationController
	before_action :init_form,  only: [:new, :create]

  def new
#    if params[:verify_email_form] && params[:verify_email_form][:verify_token]
#    	create
#    else
#    	render 'new'
#    end
  end

  def create
    p = params[:verify_email_form] || params
    if @verify_email_form.submit(p)
    	render 'verify_email_success'
    else
      render "new"
    end
  end
  
  private

    def init_form
    	@user = current_user || User.find(params[:user_id])
    	@verify_email_form = VerifyEmailForm.new(@user)
    end
end