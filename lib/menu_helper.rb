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
        attr_reader :menu_bar
        
        delegate    :menu,
                      :to => :menu_bar
        
        def initialize(id, name, options = {}, html_options = {}) #:nodoc
          @html_options = html_options.symbolize_keys
          @html_options.set_or_prepend(:class, name.to_s)
          
          @menu_bar = MenuBar.new
          @name = name
          
          if options.blank?
            if 
          end
        end
        
        # 
        def build
          sub_menu_bar = @menu_bar.build
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
        def menu(id, *args)
          @menus[id.to_sym] = Menu.new(id, *args)
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

ActionController::Routing::Routes.named_routes.install(PluginAWeek::Helpers::MenuHelper::Menu)