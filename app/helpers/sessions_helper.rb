module SessionsHelper
	#渡されたユーザーでログインする
	def log_in(user)
		session[:user_id] = user.id
	end

	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	#記憶トークンcookiesに対応するユーザーを返す
	def current_user
		if (user_id = session[:user_id])
			#user_idにユーザーIDのセッションを代入して、セッションが存在すれば
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id])
			#raise 意図的に例外を発生
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	#ユーザーがログインしていればtrue
	def logged_in?
		!current_user.nil?
	end

	#永続的セッションを破棄する
	def forget(user)
		user.forget #cookieを削除するだけではデータベースに記憶ダイジェストが残ってるので、nilで更新する。
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	#現在のユーザーをログアウトする
	def log_out
		forget(current_user)
		session.delete(:user_id) #セッション情報の削除
		@current_user = nil
	end

	#渡されたユーザーがカレントユーザーであればtrueを返す
	def current_user?(user)
		user && user == current_user
	end

	#記憶したURLに遷移
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	#アクセスしようとしたURLを記憶
	def store_location
		session[:forwarding_url] = request.original_url if request.get?
	end

end
