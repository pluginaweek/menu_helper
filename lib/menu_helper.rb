require 'set_or_append'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # 
    module MenuHelper
      # 
      def menu_bar(*args, &block)
        MainMenuBar.new(self, *args, &block)
      end
      
      # 
      class Menu
        include ActionView::Helpers::TagHelper
        
        # 
        attr_reader :id
        
        # 
        attr_reader :url_options
        
        # 
        attr_reader :menu_bar
        
        delegate    :menu,
                      :to => :menu_bar
        delegate    :url_for,
                    :link_to,
                    :current_page?,
                      :to => :@request_controller
        
        def initialize(id, request_controller, parent = nil, *args) #:nodoc
          @id = id.to_s
          @request_controller = request_controller
          @parent = parent
          
          @content = args.first.is_a?(String) ? args.shift : @id.underscore.titleize
          
          # Build the url for the menu
          @url_options = args.shift || {}
          if auto_link?
            url, @url_options = build_url(@url_options)
            @content = link_to(@content, url)
          end
          
          # Build the html options
          @html_options = args.shift || {}
          @html_options.symbolize_keys!
          @html_options[:id] ||= @id
          @html_options.set_or_append(:class, 'selected') if url && current_page?(url)
          
          @menu_bar = MenuBar.new(@request_controller, {}, {}, self)
          
          yield self if block_given?
        end
        
        def auto_link?
          !@url_options.include?(:auto_link)
        end
        
        # 
        def build(last = false)
          html = @content + @menu_bar.build
          html_options = @html_options.dup
          html_options.set_or_append(:class, 'last') if last
          
          content_tag('li', html, html_options)
        end
        
        private
        # 
        def build_url(options = {})
          # Check if the name given for the menu is a named route
          if options.blank? && route_options = (named_route(@id) || named_route(@id, @parent))
            options = route_options
          elsif options.is_a?(Hash)
            options[:controller] ||= find_controller(options)
            options[:action] ||= @id unless options[:controller] == @id
            options.reverse_merge!(@parent.url_options) if @parent
            
            # Delete options that shouldn't be merged
            options.delete(:use_route)
          end
          
          url = options.is_a?(Hash) ? url_for(options) : options
          return url, options
        end
        
        # Finds the most likely controller that this menu should link to, in
        # order of:
        # 1. The specified controller in the menu link options
        # 2. The name of the menu (e.g. products = ProductsController)
        # 3. The parent's controller
        # 4. The request controller
        def find_controller(options)
          options[:controller] ||
          Object.const_defined?("#{@id.classify}Controller") && "#{@id.classify}Controller".constantize.controller_path ||
          @parent && @parent.url_options[:controller] ||
          @request_controller.params[:controller]
        end
        
        # 
        def named_route(name, parent = nil)
          name = "#{parent.id}_#{name}" if parent
          method_name = "hash_for_#{name}_url"
          
          @request_controller.send(method_name) if @request_controller.respond_to?(method_name)
        end
      end
      
      #   
      class MenuBar
        include ActionView::Helpers::TagHelper
        
        # 
        attr_reader :menus
        
        # The collection of options to use in the menu bar's html
        attr_reader :html_options
        
        delegate    :[],
                    :[]=,
                      :to => :html_options
        
        def initialize(request_controller, options = {}, html_options = {}, parent_menu = nil) #:nodoc:
          options.assert_valid_keys(
            :auto_set_ids
          )
          options.reverse_merge!(
            :auto_set_ids => true
          )
          @options = options
          @html_options = html_options
          @request_controller = request_controller
          @parent_menu = parent_menu
          
          @menus = []
          
          yield self if block_given?
        end
        
        # 
        def menu(id, *args, &block)
          @menus << Menu.new(id, @request_controller, @parent_menu, *args, &block)
        end
        
        # 
        def build
          html = @menus.inject('') do |html, menu|
            html << menu.build(@menus.last == menu)
          end
          
          content_tag('ul', html, @html_options)
        end
      end
      
      class MainMenuBar < MenuBar
        def initialize(*args)
          super(*args)
          
          @html_options[:id] ||= 'menu_bar'
        end
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::MenuHelper
end