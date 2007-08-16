require File.dirname(__FILE__) + '/../test_helper'

class HtmlElementTest < Test::Unit::TestCase
  class DivElement < PluginAWeek::Helpers::MenuHelper::HtmlElement
    def tag_name
      'div'
    end
  end
  
  def test_html_options_on_initialization
    e = PluginAWeek::Helpers::MenuHelper::HtmlElement.new('class' => 'fancy')
    assert_equal 'fancy', e[:class]
    
    e = PluginAWeek::Helpers::MenuHelper::HtmlElement.new(:class => 'fancy')
    assert_equal 'fancy', e[:class]
  end
  
  def test_html_no_content
    assert_equal '<></>', PluginAWeek::Helpers::MenuHelper::HtmlElement.new.html
  end
  
  def test_html_with_content
    e = DivElement.new
    e.instance_eval do
      def content
        'hello world'
      end
    end
    
    assert_equal '<div>hello world</div>', e.html
  end
  
  def test_html_with_html_options
    e = DivElement.new
    e[:class] = 'fancy'
    
    assert_equal '<div class="fancy"></div>', e.html
  end
  
  def test_get_html_option
    e = PluginAWeek::Helpers::MenuHelper::HtmlElement.new
    assert_nil e[:class]
  end
  
  def test_set_html_option
    e = PluginAWeek::Helpers::MenuHelper::HtmlElement.new
    e[:float] = 'left'
    assert_equal 'left', e[:float]
  end
end
