require 'set_or_append'

module PluginAWeek #:nodoc:
  module MenuHelper
    # Represents a single menu within a menu bar
    class Menu < HtmlElement
      include ActionView::Helpers::UrlHelper
      
      # The url where this menu is linked to
      attr_reader :url_options
      
      # If there are submenus under this menu, they are stored in here
      attr_reader :menu_bar
      
      # Allow submenus to be created
      delegate    :menu,
                    :to => :menu_bar
      
      def initialize(id, request_controller, parent = nil, *args) #:nodoc
        id = id.to_s
        @controller = @request_controller = request_controller
        @parent = parent
        @content = args.first.is_a?(String) ? args.shift : id.underscore.titleize
        @url_options = args.shift || {}
        super(args.shift || {})
        
        # Set the default html options
        @html_options[:id] ||= id
        
        @menu_bar = MenuBar.new(@request_controller, {}, {:id => "#{self[:id]}_menubar"}, self)
        
        # Build the url for the menu
        url, @url_options = build_url(@url_options)
        @content = link_to(@content, url) if auto_link?
        
        yield self if block_given?
      end
      
      # Should we try to automatically generate the link?
      def auto_link?
        !@url_options.is_a?(Hash) || !@url_options.include?(:auto_link) || @url_options[:auto_link]
      end
      
      # Is this menu selected?  A menu is considered selected if it or any of
      # its submenus are selected
      def selected?
        current_page?(@url_options) || @menu_bar.menus.any? {|menu| menu.selected?}
      end
      
      # Builds the actual html of the menu
      def html(last = false)
        html_options = @html_options.dup
        html_options.set_or_append(:class, 'selected') if selected?
        html_options.set_or_append(:class, 'last') if last
        
        content_tag(tag_name, content, html_options)
      end
      
      private
        def tag_name
          'li'
        end
        
        def content
          content = @content
          content << @menu_bar.html if @menu_bar.menus.any?
          content
        end
        
        # Builds the url based on the options provided in the construction of
        # the menu
        def build_url(options = {})
          # Check if the name given for the menu is a named route
          if options.blank? && route_options = (named_route(self[:id], @parent) || named_route(self[:id]))
            options = route_options
          elsif options.is_a?(Hash)
            options[:controller] ||= find_controller(options)
            options[:action] ||= self[:id] unless options[:controller] == self[:id]
            options[:only_path] ||= false
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
          (begin; "#{self[:id].camelize}Controller".constantize.controller_path; rescue; nil; end) ||
          @parent && @parent.url_options[:controller] ||
          @request_controller.params[:controller]
        end
        
        # Finds the named route that is being linked to (if that route exists)
        def named_route(name, parent = nil)
          name = "#{parent[:id]}_#{name}" if parent
          method_name = "hash_for_#{name}_url"
          
          @request_controller.send(method_name) if @request_controller.respond_to?(method_name)
        end
    end
  end
end
