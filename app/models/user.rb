class User < ApplicationRecord
    has_secure_password
    attr_accessor :reset_token
    validates :password, presence: true, #空白を許可しない
                        length: {minimum: 6} #最低６文字必要とする
    # attr_accessor :remember_token, :activation_token, :reset_token
    # before_save   :downcase_email
    # before_create :create_activation_digest
    

    has_many :parks, dependent: :destroy
    has_many :bench_audios, dependent: :destroy
    has_many :bench_images, dependent: :destroy
    has_many :bench_videos, dependent: :destroy

    # # メールアドレスをすべて小文字にする
    # def downcase_email
    #     self.email = email.downcase
    # end

    # # ランダムなトークンを返す
    # def User.new_token
    #     SecureRandom.urlsafe_base64
    # end

    # # 有効化トークンとダイジェストを作成および代入する
    # def create_activation_digest
    #     self.activation_token  = User.new_token
    #     self.activation_digest = User.digest(activation_token)
    # end

    # # 渡された文字列のハッシュ値を返す
    # def digest(string)
    #     cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    #                                                   BCrypt::Engine.cost
    #     BCrypt::Password.create(string, cost: cost)
    # end

    

    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    # パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
end
