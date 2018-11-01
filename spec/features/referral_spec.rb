require 'feature_helper'

describe 'Referral sessions' do
  let(:password) { 'gohJ8FaimohSohk9' }
  let(:referrer) { create :user }
  let!(:refcode) { referrer.primary_referral_code }

  context 'referred user sign up' do
    let(:new_email) { Faker::Internet.email }

    it "successfully signs up" do
      visit root_path(r: refcode.code)
      click_on("Sign Up")
      submit_sign_up(new_email, password)
      expect(page).to have_content('Welcome!')
      expect(referrer.referred_visitors.registered.count).to eq 1
    end

    it "successfully signs up with wrong referral code" do
      visit root_path(r: 'qwe')
      click_on("Sign Up")
      submit_sign_up(new_email, password)
      expect(page).to have_content('Welcome!')
      expect(referrer.referred_visitors.count).to eq 0
    end
  end

  context 'referrer sees the stats' do
    before do
      login_as(referrer)
    end

    it 'shows an empty page with no stats' do
      visit_referrals_page
      snap('referrals', 'none')
    end

    it 'shows some stats' do
      referred = create(:user)
      visitor = refcode.referred_visitors.create!(referred: referred)
      visit_referrals_page
      expect(page).to have_content(visitor.created_at.year)
      snap('referrals', 'one')
    end
  end

  def visit_referrals_page
    visit root_path
    find('#session-menu__toggle').click
    click_on 'Referrals'
    expect(page).to have_content(refcode.code)
  end

  def submit_sign_up(email, password, args = {})
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: (args[:confirmation] || password) unless args[:skip_confirmation]
    snap('sessions', args[:snap_fields]) if args[:snap_fields]
    submit_form
  end
end
