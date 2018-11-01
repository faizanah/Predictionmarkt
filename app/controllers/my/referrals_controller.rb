class My::ReferralsController < ApplicationController
  def index
    @referred_visitors = current_user.referred_visitors.registered
  end
end
