class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id]) 
            #emailで適合したオブジェクトは存在する？まだ有効化してない？トークンとダイジェストは適合してる？
            user.activate #アクティベーション属性を有効化
            user.update_attribute(:activated_at, Time.zone.now) #アクティベーション日時を現在の時刻で更新
            log_in user #ここでやっとログイン！
            flash[:success] = "Account activated!"
            redirect_to user
        else
            flash[:danger] = "Invalid activation link"
            redirect_to root_url
        end
    end
end
