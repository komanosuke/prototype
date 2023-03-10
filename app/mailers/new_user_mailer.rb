class NewUserMailer < ApplicationMailer
    def send_mail(new_user)
        @user = new_user
        mail(
            from: 'komai@heart-language.jp',
            to:   @user.email,
            subject: 'お問い合わせ通知'
        )
    end
end
