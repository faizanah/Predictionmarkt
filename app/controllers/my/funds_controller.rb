class My::FundsController < ApplicationController
  # TODO: remove assign wallets
  # TODO: fail form if corrupt currency
  def index
    current_user.assign_wallets
    @transfers = current_user.currency_transfers.order('id desc').page(params[:page]).per(5)
  end

  def withdraw
    form_init
    if @form.corrupted?
      redirect_to my_funds_path
    elsif request.post? && @form.save
      process_successful_withdrawal
    end
  end

  def statement
    scope = current_user.currency_transactions.where(currency: params['currency'])
    @currency_transactions = scope.where.not(total_change: 0).order('id desc').page(params[:page]).per(25)
  end

  private

    # TODO: add user friendly dialog
    def process_successful_withdrawal
      redirect_to my_funds_path, notice: 'Done, we will process your transfer within 24 hours.'
    end

    def form_init
      @form = WithdrawForm.new(form_params.merge(user: current_user, currency: params[:currency]))
    end

    def form_params
      params.fetch(:withdraw_form, {}).permit(:address, :money, :currency)
    end
end
