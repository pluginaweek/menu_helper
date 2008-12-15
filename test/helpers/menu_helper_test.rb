require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MenuHelperTest < ActionView::TestCase
  tests MenuHelper
  
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
<ul class="pretty menubar menubar-1">
  <li><a href="http://test.host/home"><span>Home</span></a>
    <ul class="menubar menubar-2">
      <li><a href="http://test.host/home/browse"><span>Browse</span></a></li>
      <li class="menubar-last"><a href="http://test.host/home/search"><span>Search</span></a></li>
    </ul>
  </li>
  <li class="menubar-selected"><a href="http://test.host/contact"><span>Contact Us</span></a></li>
  <li class="menubar-last"><a href="http://test.host/about_us"><span>About Us</span></a></li>
</ul>
eos
    assert_equal expected.gsub(/\n\s*/, ''), menu_bar_html
  end
end
