module ReferralTrackable
  extend ActiveSupport::Concern
  included do
    before_action :intercept_referral
  end

  def intercept_referral
    reset_referral_session_if_needed
    return unless params[:r]
    r = ReferralCode.where(code: params[:r]).take
    activate_referral_if_needed(r)
    redirect_to url_for(r: nil)
  end

  private

    def reset_referral_session_if_needed
      return unless session[:r]
      session.delete(:r) if current_user
    end

    def activate_referral_if_needed(referral_code)
      return unless track_referral?(referral_code)
      logger.info "Activating referral for #{referral_code.code}"
      referred_visitor = referral_code.referred_visitors.create!
      assign_referral_session(referred_visitor)
    end

    def track_referral?(referral_code)
      return false unless referral_code
      return false if current_user || session[:r]
      true
    end

    def assign_referral_session(referred_visitor)
      session[:r] = referred_visitor.id
    end
end
