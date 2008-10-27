# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

Test::Unit::TestCase.class_eval do
  def setup
    request = ActionController::TestRequest.new
    request.request_uri = '/contact'
    request.path_parameters = {:action => 'index', :controller => 'contact'}
    
    @controller = ContactController.new
    @controller.request = request
    @controller.instance_eval {@_params = request.path_parameters}
    @controller.send(:initialize_current_url)
  end
  
  def teardown
    ActionController::Routing::Routes.load!
  end
end
