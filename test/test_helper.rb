$:.unshift("#{File.dirname(__FILE__)}/../../../ruby/hash/set_or_append/lib")

# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../../test/plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

class Test::Unit::TestCase
  def setup
    request = ActionController::TestRequest.new
    request.request_uri = '/contact'
    request.path_parameters = {:action => 'index', :controller => 'contact'}
    @controller = HomeController.new
    @controller.request = request
    @controller.instance_eval {@_params = request.path_parameters}
    @controller.send(:initialize_current_url)
  end
end
