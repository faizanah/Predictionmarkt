class My::SharesController < ApplicationController
  include My::SharesHistory
  def index
    @shares = current_user.spendable_shares.group_by(&:market)
  end

  def show
    @contract = Contract.findy(params[:id])
    @contract_transactions = contract_transactions
  end
end
