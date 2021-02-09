class User < ApplicationRecord
	attr_accessor :remember_token
	before_save { self.email.downcase! }
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true,
						length: { maximum: 255},
	          			format: { with: VALID_EMAIL_REGEX },
	          		uniqueness: true
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	#渡された文字列をハッシュ化
	def User.digest(string)
		cost =
			if ActiveModel::SecurePassword.min_cost
				BCrypt::Engine::MIN_COST
			else
				BCrypt::Engine.cost
			end
		BCrypt::Password.create(string, cost: cost)
	end

	#ランダムなトークンを返す
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	#永続セッションのためにユーザーをデータベースに残す。
	def remember
		self.remember_token = User.new_token #remember_tokenにランダムトークンを代入
		update_attribute(:remember_digest, User.digest(remember_token))
		#remember_digest属性はマイグレーション作成時に自動作成済み
	end

	#渡されたトークンがダイジェストと一致したら、trueを返す。
	def authenticated?(remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

	# ユーザーのログイン情報を破棄する
	def forget
		update_attribute(:remember_digest, nil)
	end
end
