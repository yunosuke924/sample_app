class UsersController < ApplicationController
	before_action :logged_in_user, only:[:edit,:update, :index, :destroy]
	before_action :correct_user, only:[:edit,:update]
	before_action :admin_user, only: :destroy

	def index
		@users = User.paginate(page: params[:page])
	end

	def new
		@user = User.new
	end

	def show
		@user = User.find(params[:id])
	end

	def create
		@user = User.new(user_params)
		if @user.save #saveメソッドはtrueもしくはfalseを返す。
			log_in @user #ログイン処理
			flash[:success] = 'Welcome to the Sample App!'
			redirect_to @user
		else
			render 'new' #コントローラーの名前（ビューの名前？）
		end
	end

	def edit
	end

	def update
		if @user.update(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit' #コントローラーの名前(ビューの名前？)
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
		redirect_to users_url
	end

	private

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end

	#ログイン済みユーザーかどうかの確認
	def logged_in_user
		unless logged_in?
			store_location
			flash[:danger] = "Please log in."
			redirect_to login_url
		end
	end

	#正しいユーザーかどうかの確認
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless current_user?(@user)
	end

	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end
end
