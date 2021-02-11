require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path #メール入力画面のリンクに遷移
    assert_template 'password_resets/new' #メール入力画面の表示
    assert_select 'input[name=?]', 'password_reset[email]' #inputタグのname属性の確認
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty? #フラッシュ表示が空ではない。
    assert_template 'password_resets/new' #もう一度メール入力画面が表示される
    # 今度はメールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest #リセットダイジェストが新しく取得されている。
    assert_equal 1, ActionMailer::Base.deliveries.size #送られるメールの数は一つ
    assert_not flash.empty? #フラッシュは空ではない。
    assert_redirected_to root_url #ホーム画面に遷移
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # 無効なユーザー
    user.toggle!(:activated) #アクティベートを無効化
    get edit_password_reset_path(user.reset_token, email: user.email) 
    assert_redirected_to root_url
    user.toggle!(:activated) #アクティベートを有効化
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit' #新規パスワード設定画面の表示
    assert_select "input[name=email][type=hidden][value=?]", user.email #email
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation' #id=error_explanationのdivタグがあることの確認
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end