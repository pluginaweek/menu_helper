require File.dirname(__FILE__) + '/../test_helper'

class MenuTest < Test::Unit::TestCase
  def test_default_content_should_be_humanized_id
    menu = create_menu(:home)
    assert_equal '<li id="home"><a href="http://test.host/">Home</a></li>', menu.build
  end
  
  def test_default_html_id_should_be_id
    menu = create_menu(:home)
    assert_equal 'home', menu[:id]
  end
  
  def test_should_not_linkify_if_not_auto_linking
    menu = create_menu(:home, nil, :auto_link => false)
    assert_equal '<li id="home">Home</li>', menu.build
  end
  
  def test_default_menubar_id_should_use_menu_id
    menu = create_menu(:home, nil)
    assert_equal 'home_menubar', menu.menu_bar[:id]
  end
  
  def test_should_not_auto_link_if_auto_link_is_false
    menu = create_menu(:home, nil, :auto_link => false)
    assert !menu.auto_link?
  end
  
  def test_should_auto_link_if_url_options_is_string
    menu = create_menu(:home, nil, 'http://www.google.com')
    assert menu.auto_link?
  end
  
  def test_should_auto_link_if_url_options_is_hash_without_auto_link
    menu = create_menu(:home, nil, {})
    assert menu.auto_link?
  end
  
  def test_should_be_selected_if_url_is_current_page
    menu = create_menu(:contact)
    assert menu.selected?
  end
  
  def test_should_be_selected_if_submenu_is_selected
    menu = create_menu(:home) do |home|
      home.menu :contact
    end
    assert menu.selected?
  end
  
  def test_should_be_selected_if_submenu_of_submenu_is_selected
    menu = create_menu(:home) do |home|
      home.menu :about_us do |about_us|
        about_us.menu :contact
      end
    end
    assert menu.selected?
  end
  
  def test_should_not_be_selected_if_url_is_not_current_page
    menu = create_menu(:home)
    assert !menu.selected?
  end
  
  def test_should_build_url_from_named_route_if_id_named_route_exists
    menu = create_menu(:home)
    expected = {:controller => 'home', :action => 'index', :only_path => false, :use_route => :home}
    assert_equal expected, menu.url_options
  end
  
  def test_should_build_url_from_named_route_if_id_and_parent_named_route_exists
    parent = create_menu(:home)
    menu = create_menu(:search, parent)
    expected = {:controller => 'home', :action => 'search', :only_path => false, :use_route => :home_search}
    assert_equal expected, menu.url_options
  end
  
  def test_should_use_id_as_default_controller_if_controller_exists
    menu = create_menu(:about_us)
    expected = {:controller => 'about_us', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_use_parent_controller_as_default_controller_if_id_controller_does_not_exist
    create_menu(:home) do |home|
      menu = home.menu :privacy_policy
      expected = {:controller => 'home', :action => 'privacy_policy', :only_path => false}
      assert_equal expected, menu.url_options
    end
  end
  
  def test_should_use_request_controller_as_default_controller_if_parent_and_id_controller_does_not_exist
    menu = create_menu(:investors)
    expected = {:controller => 'contact', :action => 'investors', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_use_custom_value_if_controller_is_specified
    menu = create_menu(:privacy_policy, nil, :controller => 'home')
    expected = {:controller => 'home', :action => 'privacy_policy', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_not_use_id_as_default_action_if_same_as_controller
    menu = create_menu(:about_us, nil, :controller => 'about_us')
    expected = {:controller => 'about_us', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_use_custom_value_if_action_is_specified
    menu = create_menu(:privacy_policy, nil, :controller => 'home', :action => 'privacy')
    expected = {:controller => 'home', :action => 'privacy', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_allow_string_urls
    menu = create_menu(:search, nil, 'Search', 'http://www.google.com')
    assert_equal 'http://www.google.com', menu.url_options
  end
  
  def test_should_include_selected_class_in_html_if_selected
    menu = create_menu(:contact)
    assert_equal '<li class="selected" id="contact"><a href="http://test.host/contact">Contact</a></li>', menu.build
  end
  
  def test_should_append_selected_class_if_class_attribute_already_exists
    menu = create_menu(:contact, nil, {}, :class => 'pretty')
    assert_equal '<li class="pretty selected" id="contact"><a href="http://test.host/contact">Contact</a></li>', menu.build
  end
  
  def test_should_include_last_class_in_html_if_last_menu
    menu = create_menu(:home)
    assert_equal '<li class="last" id="home"><a href="http://test.host/">Home</a></li>', menu.build(true)
  end
  
  def test_should_append_last_class_if_class_attribute_already_exists
    menu = create_menu(:home, nil, {}, :class => 'pretty')
    assert_equal '<li class="pretty last" id="home"><a href="http://test.host/">Home</a></li>', menu.build(true)
  end
  
  def test_should_not_modify_html_options_after_building_menu
    menu = create_menu(:home)
    menu.build
    assert_nil menu[:class]
  end
  
  def test_should_include_submenus_if_submenus_exist
    menu = create_menu(:home) do |home|
      home.menu :about_us do |about_us|
        about_us.menu :contact
      end
    end
    
    expected = <<-eos
<li class="selected" id="home"><a href="http://test.host/">Home</a>
  <ul id="home_menubar">
    <li class="last selected" id="about_us"><a href="http://test.host/about_us">About Us</a>
      <ul id="about_us_menubar">
        <li class="last selected" id="contact"><a href="http://test.host/contact">Contact</a></li>
      </ul>
    </li>
  </ul>
</li>
eos
    assert_equal expected.gsub(/\n\s*/, ''), menu.build
  end
  
  private
  def create_menu(id, parent = nil, *args, &block)
    PluginAWeek::Helpers::MenuHelper::Menu.new(id, @controller, parent, *args, &block)
  end
end
