# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def debug
    AdminMailer.debug(user: User.last)
  end
end
