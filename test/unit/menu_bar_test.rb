require File.dirname(__FILE__) + '/../test_helper'

class MenuBarByDefaultTest < Test::Unit::TestCase
  def setup
    super
    @menu_bar = PluginAWeek::MenuHelper::MenuBar.new(@controller)
  end
  
  def test_should_have_no_menus_by_default
    assert_equal [], @menu_bar.menus
  end
  
  def test_should_set_default_id_if_no_parent_specified
    assert_equal 'menubar', @menu_bar[:id]
  end
end

class MenuBarTest < Test::Unit::TestCase
  def test_should_raise_exception_if_invalid_option_specified
    assert_raise(ArgumentError) {create_menu_bar(:invalid => true)}
  end
  
  def test_should_accept_block
    in_block = false
    menu_bar = create_menu_bar do |main_menu|
      in_block = true
    end
    
    assert in_block
  end
  
  def test_should_create_menus
    menu_bar = create_menu_bar do |main|
      main.menu :home
      main.menu :contact
    end
    
    assert_equal 2, menu_bar.menus.size
  end
  
  def test_should_build_menu_bar_and_menus
    menu_bar = create_menu_bar do |main|
      main.menu :home
      main.menu :contact, 'Contact Us'
    end
    
    expected = <<-eos
<ul id="menubar">
  <li id="home"><a href="http://test.host/">Home</a></li>
  <li class="selected last" id="contact"><a href="http://test.host/contact">Contact Us</a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), menu_bar.html
  end
  
  private
    def create_menu_bar(*args, &block)
      PluginAWeek::MenuHelper::MenuBar.new(@controller, *args, &block)
    end
end

class MenuBarWithParentTest < Test::Unit::TestCase
  def setup
    super
    parent = PluginAWeek::MenuHelper::Menu.new(:home, @controller)
    @menu_bar = PluginAWeek::MenuHelper::MenuBar.new(@controller, {}, {}, parent)
  end
  
  def test_should_set_default_id_based_on_parent
    assert_equal 'home_menubar', @menu_bar[:id]
  end
end
