require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
		@non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin) #ログイン
    get users_path #indexページにアクセス
    assert_template 'users/index' #一覧ページの表示
    assert_select 'div.pagination' #ページネーションクラスをもったdivタグの確認
		first_page_of_users = User.paginate(page: 1)
		first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name #ページ１にユーザーがいることの確認
			unless user == @admin
				assert_select 'a[href=?]', user_path(user), text: 'delete'
			end
    end
		assert_difference 'User.count', -1 do
			delete user_path(@non_admin)
		end
  end

	test "index as non-admin" do
		log_in_as(@non_admin) #非管理者でログイン
		get users_path #一覧画面に遷移
		assert_select 'a', text: 'delete', count: 0 #名前がdeleteのaタグは０
	end
end
