require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MenuBarByDefaultTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
  end
  
  def test_should_have_no_menus
    assert_equal [], @menu_bar.menus
  end
  
  def test_should_have_a_request_controller
    assert_equal @controller, @menu_bar.request_controller
  end
  
  def test_should_have_options
    expected = {
      :auto_set_ids => true,
      :attach_active_submenus => true,
      :content_for => 'menu_bar'
    }
    assert_equal expected, @menu_bar.options
  end
  
  def test_should_have_a_level
    assert_equal 1, @menu_bar.level
  end
  
  def test_should_not_have_a_parent_menu
    assert_nil @menu_bar.parent_menu
  end
  
  def test_should_auto_set_ids
    assert @menu_bar.auto_set_ids?
  end
  
  def test_should_attach_active_submenus
    assert @menu_bar.attach_active_submenus?
  end
  
  def test_should_have_a_content_for_variable
    assert_equal '@content_for_menu_bar_level_1', @menu_bar.content_for_variable
  end
  
  def test_should_not_be_selected
    assert !@menu_bar.selected?
  end
  
  def test_should_set_css_classes
    assert_equal 'ui-menubar ui-menubar-1', @menu_bar[:class]
  end
  
  def test_should_allow_css_classes_to_be_customized
    @original_menu_bar_class = MenuHelper::MenuBar.menu_bar_class
    MenuHelper::MenuBar.menu_bar_class = 'ui-menus'
    
    menu_bar = MenuHelper::MenuBar.new(@controller)
    assert_equal 'ui-menus ui-menus-1', menu_bar[:class]
  ensure
    MenuHelper::MenuBar.menu_bar_class = @original_menu_bar_class
  end
  
  def test_should_not_set_id
    assert_nil @menu_bar[:id]
  end
end

class MenuBarTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
  end
  
  def test_should_raise_exception_if_invalid_option_specified
    assert_raise(ArgumentError) {MenuHelper::MenuBar.new(@controller, :invalid => true)}
  end
  
  def test_should_accept_block
    in_block = false
    menu_bar = MenuHelper::MenuBar.new(@controller) do |menu_bar|
      in_block = true
    end
    
    assert in_block
  end
  
  def test_should_not_modify_html_options_after_building_hml
    @menu_bar.html
    assert_equal 'ui-menubar ui-menubar-1', @menu_bar[:class]
  end
  
  def test_should_allow_menus_to_be_created
    @menu = @menu_bar.menu(:home) do |menu_bar|
      @sub_menu_bar = menu_bar
    end
    
    assert_equal @menu, @sub_menu_bar.parent_menu
    assert_equal [@menu], @menu_bar.menus
  end
end

class MenuBarWithoutMenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller)
  end
  
  def test_should_not_have_any_menus
    assert @menu_bar.menus.empty?
  end
  
  def test_should_not_be_selected
    assert !@menu_bar.selected?
  end
  
  def test_should_not_render_menus
    assert_equal '<ul class="ui-menubar ui-menubar-1"></ul>', @menu_bar.html
  end
end

class MenuBarWithCustomHtmlOptionsTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, {}, :id => 'menus', :class => 'pretty')
  end
  
  def test_should_render_with_custom_options
    assert_equal '<ul class="pretty ui-menubar ui-menubar-1" id="menus"></ul>', @menu_bar.html
  end
end

class MenuBarWithCustomContentForTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, :content_for => 'menus')
  end
  
  def test_should_have_a_content_for_variable_based_on_options
    assert_equal '@content_for_menus_level_1', @menu_bar.content_for_variable
  end
end

class MenuBarWithMenusTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, {}, :id => 'menus') do |main|
      main.menu :home
      main.menu :about_us, 'About'
    end
  end
  
  def test_should_render_menus
    expected = <<-eos
<ul class="ui-menubar ui-menubar-1" id="menus">
  <li class="ui-menubar-menu ui-menubar-menu-1" id="menus-home"><a href="http://test.host/home"><span>Home</span></a></li>
  <li class="ui-menubar-menu ui-menubar-menu-1 ui-menubar-last" id="menus-about_us"><a href="http://test.host/about_us"><span>About</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
end

class MenuBarWithSelectedMenuTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller) do |main|
      main.menu :contact
    end
  end
  
  def test_should_not_be_selected
    assert !@menu_bar.selected?
  end
  
  def test_should_not_include_selected_css_class_in_html
    expected = <<-eos
<ul class="ui-menubar ui-menubar-1">
  <li class="ui-menubar-menu ui-menubar-menu-1 ui-state-active ui-menubar-selected ui-menubar-last"><a href="http://test.host/contact"><span>Contact</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
end

class MenuBarWithoutAutoIdSettingTest < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, {:auto_set_ids => false}, :id => 'menus') do |main|
      main.menu :home
    end
  end
  
  def test_should_not_set_default_id_for_menus
    expected = <<-eos
<ul class="ui-menubar ui-menubar-1" id="menus">
  <li class="ui-menubar-menu ui-menubar-menu-1 ui-menubar-last"><a href="http://test.host/home"><span>Home</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
end

class MenuBarUnselectedWithDetachedActiveSubmenus < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, :attach_active_submenus => false) do |main|
      main.menu :home do |home|
        home.menu :about_us
      end
    end
  end
  
  def test_should_render_sub_menu_bars
    expected = <<-eos
<ul class="ui-menubar ui-menubar-1">
  <li class="ui-menubar-menu ui-menubar-menu-1 ui-menubar-last"><a href="http://test.host/home"><span>Home</span></a>
    <ul class="ui-menubar ui-menubar-2">
      <li class="ui-menubar-menu ui-menubar-menu-2 ui-menubar-last"><a href="http://test.host/about_us"><span>About Us</span></a></li>
    </ul>
  </li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
  
  def test_should_not_store_a_menu_bar_in_content_variable
    assert !@controller.instance_variable_defined?('@content_for_menu_bar_level_2')
  end
end

class MenuBarSelectedWithDetachedActiveSubmenus < Test::Unit::TestCase
  def setup
    super
    
    @menu_bar = MenuHelper::MenuBar.new(@controller, :attach_active_submenus => false) do |main|
      main.menu :contact do |contact|
        contact.menu :investors
      end
    end
  end
  
  def test_should_not_render_sub_menu_bars
    expected = <<-eos
<ul class="ui-menubar ui-menubar-1">
  <li class="ui-menubar-menu ui-menubar-menu-1 ui-state-active ui-menubar-selected ui-menubar-last"><a href="http://test.host/contact"><span>Contact</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
  
  def test_should_store_a_menu_bar_in_content_variable
    # Generate the html to store it in the variable
    @menu_bar.html
    
    expected = <<-eos
<ul class="ui-menubar ui-menubar-2">
  <li class="ui-menubar-menu ui-menubar-menu-2 ui-menubar-last"><a href="http://test.host/contact/investors"><span>Investors</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @controller.instance_variable_get('@content_for_menu_bar_level_2')
  end
end

class MenuBarWithParentMenuTest < Test::Unit::TestCase
  def setup
    super
    
    @parent_menu_bar = MenuHelper::MenuBar.new(@controller)
    @parent_menu = MenuHelper::Menu.new(@parent_menu_bar, :home) 
    @menu_bar = MenuHelper::MenuBar.new(@controller, :parent_menu => @parent_menu)
  end
  
  def test_should_have_a_parent_menu
    assert_equal @parent_menu, @menu_bar.parent_menu
  end
  
  def test_should_have_level
    assert_equal 2, @menu_bar.level
  end
end

class MenuBarWithParentMenuAndSelectedMenuTest < Test::Unit::TestCase
  def setup
    super
    
    @parent_menu_bar = MenuHelper::MenuBar.new(@controller)
    @parent_menu = MenuHelper::Menu.new(@parent_menu_bar, :about_us) 
    @menu_bar = MenuHelper::MenuBar.new(@controller, :parent_menu => @parent_menu) do |about_us|
      about_us.menu :contact
    end
  end
  
  def test_should_be_selected
    assert @menu_bar.selected?
  end
  
  def test_should_include_selected_css_class_in_html
    expected = <<-eos
<ul class="ui-menubar ui-menubar-2 ui-state-active ui-menubar-selected">
  <li class="ui-menubar-menu ui-menubar-menu-2 ui-state-active ui-menubar-selected ui-menubar-last"><a href="http://test.host/contact"><span>Contact</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), @menu_bar.html
  end
end
