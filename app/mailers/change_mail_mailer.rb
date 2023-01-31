class ChangeMailMailer < ApplicationMailer
    def send_mail(user)
        @user = user
        mail(
            from: 'komai@heart-language.jp',
            to:   @user.email,
            subject: 'お問い合わせ通知'
        )
    end
end
