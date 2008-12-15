require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MenuByDefaultTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_have_a_name
    assert_equal 'home', @menu.name
  end
  
  def test_should_have_a_request_controller
    assert_equal @controller, @menu.request_controller
  end
  
  def test_should_have_a_parent_menu_bar
    assert_equal @menu_bar, @menu.parent_menu_bar
  end
  
  def test_should_not_have_a_parent_menu
    assert_nil @menu.parent_menu
  end
  
  def test_should_auto_set_ids
    assert @menu.auto_set_ids?
  end
  
  def test_should_attach_active_submenus
    assert @menu.attach_active_submenus?
  end
  
  def test_should_not_add_an_html_id
    assert_nil @menu[:id]
  end
  
  def test_should_not_be_selected
    assert !@menu.selected?
  end
end

class MenuTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_accept_a_block
    in_block = false
    menu = MenuHelper::Menu.new(@menu_bar, :home) do |menu|
      in_block = true
    end
    
    assert in_block
  end
  
  def test_should_include_last_class_in_html_if_last_menu
    assert_equal '<li class="menubar-last"><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html(true)
  end
  
  def test_should_append_last_class_if_class_attribute_already_exists
    @menu[:class] = 'pretty'
    assert_equal '<li class="pretty menubar-last"><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html(true)
  end
  
  def test_should_allow_last_class_to_be_customized
    @original_last_class = MenuHelper::Menu.last_class
    MenuHelper::Menu.last_class = 'menubar-end'
    
    assert_equal '<li class="menubar-end"><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html(true)
  ensure
    MenuHelper::Menu.last_class = @original_last_class
  end
  
  def test_should_not_modify_html_options_after_building_html
    @menu.html(true)
    assert_nil @menu[:class]
  end
end

class MenuWithMatchingNamedRouteTest < Test::Unit::TestCase
  def setup
    super
    
    ActionController::Routing::Routes.draw do |map|
      map.home '', :controller => 'home', :action => 'index'
    end
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_build_url_from_named_route
    expected = {:controller => 'home', :action => 'index', :only_path => false, :use_route => :home}
    assert_equal expected, @menu.url_options
  end
end

class MenuWithMatchingControllerTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_use_name_as_controller
    expected = {:controller => 'home', :only_path => false}
    assert_equal expected, @menu.url_options
  end
end

class MenuWithoutMatchingNamedRouteOrControllerTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :investors)
  end
  
  def test_should_use_request_controller_as_controller_and_name_as_action
    expected = {:controller => 'contact', :action => 'investors', :only_path => false}
    assert_equal expected, @menu.url_options
  end
end

class MenuWithCustomUrlOptionsTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
  end
  
  def test_should_use_custom_controller_if_specified
    menu = MenuHelper::Menu.new(@menu_bar, :privacy_policy, :controller => 'home')
    expected = {:controller => 'home', :action => 'privacy_policy', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_not_use_name_as_action_if_same_as_controller_name
    menu = MenuHelper::Menu.new(@menu_bar, :about_us, :controller => 'about_us')
    expected = {:controller => 'about_us', :only_path => false}
    assert_equal expected, menu.url_options
  end
  
  def test_should_use_custom_action_if_specified
    menu = MenuHelper::Menu.new(@menu_bar, :privacy_policy, :controller => 'home', :action => 'privacy')
    expected = {:controller => 'home', :action => 'privacy', :only_path => false}
    assert_equal expected, menu.url_options
  end
end

class MenuWithSpecificUrlTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :search, 'Search', 'http://www.google.com')
  end
  
  def test_should_use_exact_url
    assert_equal 'http://www.google.com', @menu.url_options
  end
end

class MenuWithMenubarId < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, {}, :id => 'menus')
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_prefix_menu_id_with_menu_bar_id
    assert_equal 'menus-home', @menu[:id]
  end
end

class MenuWithoutContentTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_use_titleized_version_of_name_as_content
    assert_equal '<li><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html
  end
end

class MenuWithCustomContentTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home, 'My Home')
  end
  
  def test_should_use_custom_content_as_content
    assert_equal '<li><a href="http://test.host/home"><span>My Home</span></a></li>', @menu.html
  end
end

class MenuWithoutLinkingTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home, {}, :link => false)
  end
  
  def test_should_not_linkify_html
    assert_equal '<li><span>Home</span></li>', @menu.html
  end
end

class MenuWithoutAutoIdSettingTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, {:auto_set_ids => false}, :id => 'menus')
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_not_set_default_id
    assert_nil @menu[:id]
  end
end

class MenuWhenNotCurrentPageTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_not_be_selected
    assert !@menu.selected?
  end
  
  def test_should_not_include_selected_css_class_in_html
    assert_equal '<li><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html
  end
end

class MenuWhenCurrentPageTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :contact)
  end
  
  def test_should_be_selected
    assert @menu.selected?
  end
  
  def test_should_include_selected_css_class_in_html
    assert_equal '<li class="menubar-selected"><a href="http://test.host/contact"><span>Contact</span></a></li>', @menu.html
  end
  
  def test_should_append_selected_class_if_class_attribute_already_exists
    @menu[:class] = 'pretty'
    assert_equal '<li class="pretty menubar-selected"><a href="http://test.host/contact"><span>Contact</span></a></li>', @menu.html
  end
  
  def test_should_allow_selected_class_to_be_customized
    @original_selected_class = MenuHelper::Menu.selected_class
    MenuHelper::Menu.selected_class = 'menubar-active'
    assert_equal '<li class="menubar-active"><a href="http://test.host/contact"><span>Contact</span></a></li>', @menu.html
  ensure
    MenuHelper::Menu.selected_class = @original_selected_class
  end
end

class MenuWithoutSubmenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home)
  end
  
  def test_should_not_render_a_menu_bar
    assert_equal '<li><a href="http://test.host/home"><span>Home</span></a></li>', @menu.html
  end
end

class MenuWithSubmenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :home) do |home|
      home.menu :about_us do |about_us|
        about_us.menu :who_we_are
      end
    end
  end
  
  def test_should_render_a_menu_bar
    expected = <<-eos
<li><a href="http://test.host/home"><span>Home</span></a>
  <ul class="menubar menubar-2">
    <li class="menubar-last"><a href="http://test.host/about_us"><span>About Us</span></a>
      <ul class="menubar menubar-3">
        <li class="menubar-last"><a href="http://test.host/about_us/who_we_are"><span>Who We Are</span></a></li>
      </ul>
    </li>
  </ul>
</li>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu.html
  end
end

class MenuUnselectedWithDetachedActiveSubmenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, :attach_active_submenus => false)
    @menu = MenuHelper::Menu.new(@menu_bar, :home) do |home|
      home.menu :about_us
    end
  end
  
  def test_should_render_a_menu_bar
    expected = <<-eos
<li><a href="http://test.host/home"><span>Home</span></a>
  <ul class="menubar menubar-2">
    <li class="menubar-last"><a href="http://test.host/about_us"><span>About Us</span></a></li>
  </ul>
</li>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu.html
  end
  
  def test_should_not_store_a_menu_bar_in_content_variable
    assert !@controller.instance_variable_defined?('@content_for_menu_bar_level_2')
  end
end

class MenuSelectedWithDetachedActiveSubmenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, :attach_active_submenus => false)
    @menu = MenuHelper::Menu.new(@menu_bar, :contact) do |contact|
      contact.menu :investors
    end
  end
  
  def test_should_not_render_a_menu_bar
    assert_equal '<li class="menubar-selected"><a href="http://test.host/contact"><span>Contact</span></a></li>', @menu.html
  end
  
  def test_should_store_a_menu_bar_in_content_variable
    # Generate the html to store it in the variable
    @menu.html
    
    expected = <<-eos
<ul class="menubar menubar-2">
  <li class="menubar-last"><a href="http://test.host/contact/investors"><span>Investors</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @controller.instance_variable_get('@content_for_menu_bar_level_2')
  end
end

class MenuWithSubmenuAsCurrentPageTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @menu = MenuHelper::Menu.new(@menu_bar, :about_us) do |about_us|
      about_us.menu :contact
    end
  end
  
  def test_should_be_selected
    assert @menu.selected?
  end
  
  def test_should_include_selected_css_class_in_html
    expected = <<-eos
<li class="menubar-selected"><a href="http://test.host/about_us"><span>About Us</span></a>
  <ul class="menubar menubar-2 menubar-selected">
    <li class="menubar-selected menubar-last"><a href="http://test.host/contact"><span>Contact</span></a></li>
  </ul>
</li>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu.html
  end
end

class MenuWithParentMenuTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @parent_menu = MenuHelper::Menu.new(@menu_bar, :contact, {}, :id => 'contact')
    @menu = @parent_menu.menu :investors
  end
  
  def test_should_have_a_parent_menu
    assert_equal @parent_menu, @menu.parent_menu
  end
  
  def test_should_prefix_menu_id_with_parent_menu_id
    assert_equal 'contact-investors', @menu[:id]
  end
end

class MenuWithParentMenuAndMatchingNamedRouteTest < Test::Unit::TestCase
  def setup
    super
    
    ActionController::Routing::Routes.draw do |map|
      map.contact_investors 'contact/investors', :controller => 'contact', :action => 'investors'
      map.connect ':controller/:action/:id'
    end
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @parent_menu = MenuHelper::Menu.new(@menu_bar, :contact)
    @menu = @parent_menu.menu :investors
  end
  
  def test_should_build_url_from_named_route
    expected = {:controller => 'contact', :action => 'investors', :only_path => false, :use_route => :contact_investors}
    assert_equal expected, @menu.url_options
  end
end

class MenuWithParentMenuAndMatchingControllerTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
    @parent_menu = MenuHelper::Menu.new(@menu_bar, :contact)
    @menu = @parent_menu.menu :investors
  end
  
  def test_should_use_parent_controller_as_controller
    expected = {:controller => 'contact', :action => 'investors', :only_path => false}
    assert_equal expected, @menu.url_options
  end
end
