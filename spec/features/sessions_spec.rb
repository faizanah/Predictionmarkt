require 'feature_helper'

describe 'User sessions' do
  let(:password) { 'gohJ8FaimohSohk9' }

  context 'new users sign up' do
    let(:new_email) { Faker::Internet.email }

    before do
      clear_emails
      visit root_path
      click_on 'Sign Up'
    end

    it "successfully signs up" do
      expect(page).to have_content('Password')
      snap('sessions', 'sign-up')
      submit_sign_up(new_email, password, snap_fields: 'sign-up-fields')
      expect(page).to have_content('Welcome!')
      snap('sessions', 'signed-up')
    end

    it 'sends a sign-up email' do
      perform_enqueued_jobs { submit_sign_up(new_email, password) }
      open_email(new_email)
      snap_email('sessions', 'email-signed-up')
      current_email.click_link 'Confirm my account'
      snap('sessions', 'confirmed')
      expect(page).to have_content 'successfully confirmed'
    end

    it "fails on password mismatch" do
      submit_sign_up(new_email, password, confirmation: '42', snap_fields: 'password-mismatch-fields')
      expect(page).to have_content("doesn't match")
      snap('sessions', 'password-mismatch')
    end

    it "fails on short password" do
      submit_sign_up(new_email, '42')
      expect(page).to have_content("too short")
      snap('sessions', 'password-short')
    end

    it "fails on existing email" do
      user = create(:user)
      submit_sign_up(user.email, password)
      expect(page).to have_content("been taken")
      snap('sessions', 'existing-email')
    end
  end

  context 'existing users sign in' do
    let(:user) { create(:user, password: password) }

    before do
      visit root_path
      click_on 'Sign In'
    end

    it "successfully signs in" do
      expect(page).to have_content('Password')
      snap('sessions', 'sign-in')
      submit_sign_in(user.email, password, snap_fields: 'filled-sign-in')
      expect(page).to have_content('successfully')
      snap('sessions', 'signed-in')
    end

    it "fails on password mismatch" do
      submit_sign_in(user.email, 'wrong-password')
      expect(page).to have_content("Invalid Email or password")
      snap('sessions', 'sign-in-wrong-password')
    end

    it "fails on non-existent user" do
      user = create(:user)
      submit_sign_in('nonexistent' + user.email, password)
      expect(page).to have_content("Invalid Email or password")
      snap('sessions', 'nonexistent-user')
    end
  end

  def submit_sign_up(email, password, args = {})
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: (args[:confirmation] || password) unless args[:skip_confirmation]
    snap('sessions', args[:snap_fields]) if args[:snap_fields]
    submit_form
  end

  def submit_sign_in(email, password, args = {})
    submit_sign_up(email, password, args.merge(skip_confirmation: true))
  end

  context 'signed in users sign out' do
    let(:user) { create(:user, password: password) }

    before do
      login_as(user.reload)
      visit root_path
    end

    it 'signs out' do
      find('#session-menu__toggle').click
      expect(page).to have_content("Sign Out")
      snap('sessions', 'sign-out-menu')
      click_on("Sign Out")
      expect(page).to have_content("Signed out")
      snap('sessions', 'signed-out')
    end
  end
end
