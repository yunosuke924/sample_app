ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  fixtures :all
  include ApplicationHelper
  
  def is_logged_in?
    !session[:user_id].nil?
  end
end
