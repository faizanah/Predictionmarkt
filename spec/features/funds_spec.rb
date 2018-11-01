require 'feature_helper'

describe 'Funds withdrawal' do
  let(:default_amount) { 10_000 }
  let(:eth_address) { ApplicationCurrency.get('eth').generate_key[:address] }

  context 'for users with no money' do
    let(:user) { create :user }

    before { login_as(user.reload) }

    it "shows no funds" do
      visit my_funds_path
      expect(page).to have_content('Balance')
      snap('funds', 'zero-balance')
    end

    it 'shows an empty statement' do
      visit statement_my_funds_path(currency: 'ETH')
      expect(page).to have_content(/Statement/i)
      snap('funds', 'statement')
    end
  end

  context 'for users with money', type: :feature do
    let(:user_with_money) { create(:user, :with_all_currencies, default_amount: default_amount) }

    before { login_as(user_with_money.reload) }

    it "shows funds" do
      visit my_funds_path
      expect(page).to have_content('Balance')
      snap('funds', 'full-balance')
    end

    it "shows withdraw form" do
      visit withdraw_my_funds_path(currency: 'eth')
      expect(page).to have_content('Withdraw')
      snap('funds', 'withdraw')
      fill_in 'withdraw_form_address', with: eth_address
      click_on 'Continue'
      snap('funds', 'withdraw-sent')
    end

    it "shows errors form" do
      visit withdraw_my_funds_path(currency: 'btc')
      snap('funds', 'withdraw')
      fill_in 'withdraw_form_address', with: 'wrong-address'
      click_on 'Continue'
      snap('funds', 'withdraw-error')
      expect(page).to have_content('is invalid')
    end
  end
end
