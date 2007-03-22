require 'set_or_append'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # 
    module MenuHelper
      # 
      def menu_bar(options = {}, html_options = {}, &block)
        MenuBar.new(options, html_options, &block)
      end
      
      # 
      class Menu
        include ActionView::Helpers::TagHelper
        
        # The collection of options to use in the cell's html
        attr_reader :html_options
        
        delegate    :[],
                    :[]=,
                      :to => :html_options
        
        def initialize(tag_name, class_name, content = class_name.to_s.titleize, html_options = {}) #:nodoc
          @html_options = html_options.symbolize_keys
          @html_options.set_or_prepend(:class, class_name.to_s)
          
          @tag_name, @content = tag_name, content
        end
        
        # 
        def build
          content_tag(@tag_name, @content, @html_options)
        end
      end
      
      #   
      class MenuBar
        include ActionView::Helpers::TagHelper
        
        # 
        attr_reader :menus
        
        def initialize(collection, options = {}, html_options = {}) #:nodoc:
          @html_options = html_options
          @html_options.set_or_prepend(:class, 'menu_bar')
          
          @menus = ActiveSupport::OrderedHash.new
          
          yield self if block_given?
        end
        
        # 
        def menu(name, caption = class_name.to_s.titleize)
          @menus[class_name] = caption
        end
        
        # 
        def build
          html = ''
        end
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::MenuHelper
end