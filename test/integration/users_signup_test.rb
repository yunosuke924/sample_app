require 'test_helper'
#ユーザー登録ボタンを押したときに、ユーザー情報が無効のため、ユーザー作成ができないことを検証
class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar"}}
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect! #リダイレクトの確認
    assert_template 'users/show' #ビューが正しく表示されるかの確認
    assert_not flash.blank? #フラッシュが空白ではないことの確認
  end
end
