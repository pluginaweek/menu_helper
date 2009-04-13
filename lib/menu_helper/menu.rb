module MenuHelper
  # Represents a single menu within a menu bar
  class Menu < HtmlElement
    include ActionView::Helpers::UrlHelper
    
    # The css class to apply for each menu
    cattr_accessor :menu_class
    @@menu_class = 'ui-menubar-menu'
    
    # The css class to apply when a menu is selected
    cattr_accessor :selected_class
    @@selected_class = 'ui-state-active ui-menubar-selected'
    
    # The css class for the last menu in the menu bar
    cattr_accessor :last_class
    @@last_class = 'ui-menubar-last'
    
    # The unique name assigned to this menu
    attr_reader :name
    
    # The url where this menu is linked to.  This can either be a hash of
    # url options or a string representing the actual url
    attr_reader :url_options
    
    # The menu bar in which this menu exists
    attr_reader :parent_menu_bar
    
    # Add shortcuts to the menu bar configuration
    delegate  :request_controller,
              :parent_menu,
              :level,
              :auto_set_ids?,
              :attach_active_submenus?,
                :to => :parent_menu_bar
    
    # Add ability to add menus *after* creation
    delegate  :menu,
                :to => '@menu_bar'
    
    def initialize(parent_menu_bar, name, content = nil, url_options = {}, html_options = {}) #:nodoc
      # Allow the content parameter to be skipped
      content, url_options, html_options = nil, content, url_options if content.is_a?(Hash)
      
      # Remove non-html options that are specific to this element and shouldn't
      # be rendered as an html attribute
      @options = html_options.slice(:link)
      html_options.except!(:link)
      
      super(html_options)
      
      @parent_menu_bar = parent_menu_bar
      @name = name.to_s
      
      # Set context of the menu for url generation
      @controller = request_controller
      
      # Generate the text-based content of the menu
      @content = content_tag(:span, content || @name.underscore.titleize)
      
      # Set up url
      url, @url_options = build_url(url_options)
      @content = link_to(@content, url) if @options[:link] != false
      
      # Set up default html options
      id_prefix = parent_menu_bar[:id] || parent_menu && parent_menu[:id]
      self[:id] ||= "#{id_prefix}-#{@name}" if auto_set_ids? && id_prefix
      self[:class] = "#{self[:class]} #{menu_class} #{menu_class}-#{level}".strip
      
      # Create the menu bar for sub-menus in case any are generated.  Use the
      # same configuration as the parent menu bar.
      @menu_bar = MenuBar.new(request_controller, parent_menu_bar.options.merge(:parent_menu => self))
      
      yield @menu_bar if block_given?
    end
    
    # Is this menu selected?  A menu is considered selected if it or any of
    # its sub-menus are selected
    def selected?
      current_page?(url_options) || @menu_bar.selected?
    end
    
    # Builds the actual html of the menu
    def html(last = false)
      html_options = @html_options.dup
      html_options[:class] = "#{html_options[:class]} #{selected_class}".strip if selected?
      html_options[:class] = "#{html_options[:class]} #{last_class}".strip if last
      
      content_tag(tag_name, content, html_options)
    end
    
    private
      # List item
      def tag_name
        'li'
      end
      
      # Generate the html for the menu
      def content
        content = @content
        
        if @menu_bar.menus.any?
          # sub-menus have been defined: render markup
          html = @menu_bar.html
          
          if attach_active_submenus? || !selected?
            content << html
          else
            # sub-menu bar will be generated elsewhere
            request_controller.instance_variable_set(@menu_bar.content_for_variable, html)
          end
        end
        
        content
      end
      
      # Builds the url based on the options provided in the construction of
      # the menu
      def build_url(options = {})
        # Check if the name given for the menu is a named route
        if options.blank? && route_options = (named_route(name) || named_route(name, false))
          options = route_options
        elsif options.is_a?(Hash)
          options[:controller] ||= find_controller(options)
          options[:action] ||= name unless options[:controller] == name
          options[:only_path] ||= false
        end
        
        url = options.is_a?(Hash) ? url_for(options) : options
        return url, options
      end
      
      # Finds the most likely controller that this menu should link to
      def find_controller(options)
        # 1. Specified controller in the menu link options
        options[:controller] ||
        # 2. The name of the menu (e.g. products = ProductsController)
        (begin; "#{name.camelize}Controller".constantize.controller_path; rescue; end) ||
        # 3. The parent's controller
        parent_menu && parent_menu.url_options[:controller] ||
        # 4. The request controller
        request_controller.class.controller_path
      end
      
      # Finds the named route that is being linked to (if that route exists)
      def named_route(name, include_parent = true)
        name = "#{parent_menu.name}_#{name}" if parent_menu && include_parent
        method_name = "hash_for_#{name}_url"
        
        request_controller.send(method_name) if request_controller.respond_to?(method_name)
      end
  end
end
