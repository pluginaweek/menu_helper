require File.dirname(__FILE__) + '/../test_helper'

class MenuHelperTest < Test::Unit::TestCase
  include PluginAWeek::Helpers::MenuHelper
  
  def test_should_build_menu_bar
    menu_bar_html = menu_bar({}, :class => 'pretty') do |main|
      main.menu :home do |home|
        home.menu :browse
        home.menu :search
      end
      main.menu :contact, 'Contact Us'
      main.menu :about_us
    end
    
    expected = <<-eos
<ul class="pretty" id="menubar">
  <li id="home"><a href="http://test.host/">Home</a>
    <ul id="home_menubar">
      <li id="browse"><a href="http://test.host/home/browse">Browse</a></li>
      <li class="last" id="search"><a href="http://test.host/search_stuff">Search</a></li>
    </ul>
  </li>
  <li class="selected" id="contact"><a href="http://test.host/contact">Contact Us</a></li>
  <li class="last" id="about_us"><a href="http://test.host/about_us">About Us</a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), menu_bar_html
  end
end
