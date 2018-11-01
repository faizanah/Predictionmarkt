class AdminMailer < ApplicationMailer
  def registered(user)
    @email = user.email
    @user = user
    mail to: 'lex@predictionmarkt.com', subject: 'New user sign up'
  end

  def support_request(request)
    @user = request.user
    @request = request
    mail to: 'lex@predictionmarkt.com',
         subject: 'PredictionMarkt: Support request',
         reply_to: @request.user.email do |format|
      format.html { render 'user_mailer/support_request' }
    end
  end

  def debug(args = {})
    @args = args
    mail to: 'lex@predictionmarkt.com', subject: 'PredictionMarkt: debug'
  end
end
