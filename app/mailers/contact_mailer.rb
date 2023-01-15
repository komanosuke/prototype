class ContactMailer < ApplicationMailer
    def send_mail(contact)
        @contact = contact
        mail(
            from: 'komai@heart-language.jp',
            to:   'komai@heart-language.jp',
            subject: 'お問い合わせ通知'
        )
    end
end