# Preview all emails at http://localhost:3000/rails/mailers/new_user_mailer
class NewUserMailerPreview < ActionMailer::Preview
    def new_user
        new_user = User.new(email: "toshihiko.komai616@gmail.com")
       
        NewUserMailer.send_mail(new_user)
    end
end
