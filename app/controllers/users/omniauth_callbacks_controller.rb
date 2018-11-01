# rubocop:disable Style/ClassAndModuleChildren
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    callback_from :facebook
  end

  def twitter
    callback_from :twitter
  end

  def google_oauth2
    callback_from :google
  end

  private

    def callback_from(provider)
      provider = provider.to_s

      @user = User.from_omniauth(request.env['omniauth.auth'])
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication # will throw if @user is not activated
      else
        session["devise.#{provider}_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url
      end
    end

    def failure
      redirect_to root_path
    end
end
