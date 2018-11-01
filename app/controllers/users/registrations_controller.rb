class Users::RegistrationsController < Devise::RegistrationsController
  protected

    def build_resource(*args)
      res = super
      update_referred_visitor(res)
    end

    def update_referred_visitor(res)
      return unless session[:r]
      res.referred_visitor_session = session[:r]
    end
end
