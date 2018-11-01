def authenticated_user
  user = create(:user, :with_wallets)
  sign_in(user, scope: :user)
  user
end
