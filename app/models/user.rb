class User < ApplicationRecord
	has_many :microposts, dependent: :destroy #:destroyはオプション。userが消滅すると、micropostsも消える。
	has_many :active_relationships, class_name:  "Relationship",
									foreign_key: "follower_id",
									dependent:   :destroy
	has_many :passive_relationships, class_name:  "Relationship",
									foreign_key: "followed_id",
									dependent:   :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	attr_accessor :remember_token, :activation_token, :reset_token #仮の属性
	before_save   :downcase_email #ブロックを渡すよりメソッドを参照する方が良いので変更
	before_create :create_activation_digest #有効化のトークン作成、ダイジェスト化
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
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	# ユーザーのログイン情報を破棄する
	def forget
		update_attribute(:remember_digest, nil)
	end

	 # アカウントを有効にする
	def activate
		update_attribute(:activated,    true)
		update_attribute(:activated_at, Time.zone.now)
	end
	
	  # 有効化用のメールを送信する
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	# パスワード再設定の属性を設定する
	def create_reset_digest
		self.reset_token = User.new_token
		update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
		#update_attribute(:reset_digest,  User.digest(reset_token))
		#update_attribute(:reset_sent_at, Time.zone.now)
	end
	
	  # パスワード再設定のメールを送信する
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	# ユーザーのステータスフィードを返す
	def feed
		following_ids = "SELECT followed_id FROM relationships
						 WHERE follower_id = :user_id"
		Micropost.where("user_id IN (#{following_ids})
						 OR user_id = :user_id", user_id: id)
	end

	# ユーザーをフォローする
	def follow(other_user)
		following << other_user
	end

	# ユーザーをフォロー解除する
	def unfollow(other_user)
	active_relationships.find_by(followed_id: other_user.id).destroy
	end

	# 現在のユーザーがフォローしてたらtrueを返す
	def following?(other_user)
	following.include?(other_user)
	end

	private

	def downcase_email
		self.email = email.downcase
	end
  
	  # 有効化トークンとダイジェストを作成および代入する
	def create_activation_digest
		self.activation_token  = User.new_token #2行目で定義した仮の属性アクティベーショントークンに新規トークンを代入
		self.activation_digest = User.digest(activation_token)
	end
end
