class MicropostsController < ApplicationController
    before_action :logged_in_user, only: [:create, :destroy]
    before_action :correct_user,   only: :destroy
  
	def create
		@micropost = current_user.microposts.build(micropost_params) #空のmicropostインスタンスを作成
		@micropost.image.attach(params[:micropost][:image])
		@feed_items = current_user.feed.paginate(page: params[:page])
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			render 'static_pages/home'
			#redirect_to root_path
		end
	end

	def destroy
		@micropost.destroy
		flash[:success] = "Micropost deleted"
		redirect_to request.referrer || root_url
	end

private

	def micropost_params
		params.require(:micropost).permit(:content, :image)
	end

	def correct_user
		@micropost = current_user.microposts.find_by(id: params[:id])
		redirect_to root_url if @micropost.nil?
	end
end