module PluginAWeek #:nodoc:
  module MenuHelper
    # Represents a group of menus.  A menu bar can either be the main menu bar
    # or a menu bar nested within a menu.
    class MenuBar < HtmlElement
      # The css class to apply for all menu bars
      cattr_accessor :menu_bar_class
      @@menu_bar_class = 'menubar'
      
      # The css class to apply when a sub-menu bar is selected
      cattr_accessor :selected_class
      @@selected_class = 'menubar-selected'
      
      # The request context in which this menu bar is being rendered
      attr_reader :request_controller
      
      # The menus within this menu bar
      attr_reader :menus
      
      # The configuration options for this menu bar
      attr_reader :options
      
      def initialize(request_controller, options = {}, html_options = {}) #:nodoc:
        super(html_options)
        
        # Set up default options
        options.assert_valid_keys(:parent_menu, :auto_set_ids, :attach_active_submenus, :content_for)
        options.reverse_merge!(:auto_set_ids => true, :attach_active_submenus => true, :content_for => 'menu_bar')
        @options = options
        
        # Set context of the menu bar (the request and any parent)
        @request_controller = request_controller
        
        # No menus initially associated
        @menus = []
        
        # Set up default html options
        self[:class] = "#{self[:class]} #{menu_bar_class} #{menu_bar_class}-#{level}".strip
        
        yield self if block_given?
      end
      
      # Gets the nesting level of this menu bar.  The top-level menu bar will
      # always have a nesting level of 1.
      def level
        @level ||= begin
          level = 1
          
          # Keep walking up the tree, until first-level menus are encountered
          menu = parent_menu
          while menu
            level += 1
            menu = menu.parent_menu
          end
          
          level
        end
      end
      
      # The menu in which this menu bar is being displayed.  This will be nil if
      # this is the main menu bar.
      def parent_menu
        @options[:parent_menu]
      end
      
      # Shoulds elements have default ids automatically applied to them?
      def auto_set_ids?
        @options[:auto_set_ids]
      end
      
      # Should menu bars in sub-menus be attached to this menu bar?
      def attach_active_submenus?
        @options[:attach_active_submenus]
      end
      
      # The instance variable to use when rendering the current active sub-menu
      # bar
      def content_for_variable
        "@content_for_#{@options[:content_for]}_level_#{level}"
      end
      
      # Is this menu bar selected?  A menu bar is considered selected if it has
      # a parent menu and that parent menu is selected.
      def selected?
        parent_menu && menus.any? {|menu| menu.selected?}
      end
      
      # Creates a new menu in this bar with the given id.  The content
      # within the menu is, by default, set to a humanized version of the id.
      # 
      # == URLs with routes
      # 
      # If you have named routes set up in the application, the menu attempts
      # to automatically figure out what URL you're trying to link to.  It
      # does this by looking at the id of the menu and the id of its parent.
      # 
      # For example, a menu bar with the id 'home' and a menu with the id
      # 'contact_us' will attempt to look for the following named routes as
      # the URL to link to (in order of priority):
      # 1. home_contact_us_url
      # 2. contact_us_url
      # 
      # Example routes.rb:
      # 
      #   ActionController::Routing::Routes.draw do |map|
      #     map.with_options(:controller => 'home') do |home|
      #       home.home '', :action => 'index'
      #       home.home_search 'search', :action => 'search'
      #     end
      #     
      #     map.with_options(:controller => 'about_us') do |about_us|
      #       about_us.about_us 'about_us', :action => 'index'
      #     end
      #   end
      # 
      # Example menu bar:
      # 
      #   menu_bar :home do |home|
      #     home.menu :about_us   # => Links to about_us_url
      #     home.menu :search     # => Links to home_search_url
      #   end
      # 
      # == URLs with url_for
      # 
      # If neither of these named routes are being used, the url will be based
      # on the options passed into the menu.  The url_options takes the same
      # values as +url_for+.  By default, the name of the controller will be
      # guessed in the following order:
      # 1. The id of the menu ('contact_us' => ContactUsController)
      # 2. The controller of the parent menu/menu bar
      # 3. The request controller
      # 
      # To override the default controller being linked to, you can explicitly
      # define it like so:
      #   menu :contact, 'Contact Us', :controller => 'about_us'
      # 
      # Examples:
      # 
      #   menu :home do |home|
      #     home.menu :about, 'About Us', :action => 'about_us'                       # => Links to {:controller => 'home', :action => 'about_us'}
      #     home.menu :who_we_are                                                     # => Links to {:controller => 'home', :action => 'who_we_are'}
      #     home.menu :contact_us, :controller => 'contact', :action => 'index'  # => Links to {:controller => 'contact', :action => 'index'}
      #     home.menu :search                                                         # => Links to {:controller => 'search'}
      #   end
      # 
      # You can also link to an explicit URL like so:
      # 
      #   home.menu :search, 'http://www.google.com'
      # 
      # == Turning off links
      # 
      # If you don't want a menu to link to a URL, you can turn off linking like
      # so:
      # 
      #   home.menu :contact_us, {}, :link => false
      # 
      # == Defining content and html attributes
      # 
      # By default, the content within a menu will be set as a humanized
      # version of the menu's id.  Examples of menus which customize the
      # content and/or html attributes are below:
      # 
      #   home.menu :contact                                          # => <li id="contact"><a href="/contact">Contact</a></li>
      #   home.menu :contact, 'Contact Us'                            # => <li id="contact"><a href="/contact">Contact Us</a></li>
      #   home.menu :contact, {}, :class => 'pretty'                  # => <li id="contact" class="pretty"><a href="/contact">Contact</a></li>
      #   home.menu :contact, 'Get in touch!', {}, :class => 'pretty' # => <li id="contact" class="pretty"><a href="/contact">Contact Us</a></li>
      # 
      # == Sub-menus
      # 
      # Menus can also have their own sub-menus by passing in a block.  You can
      # create sub-menus in the same manner that the main menus are created.
      # For example,
      # 
      #   home.menu :about do |about|
      #     about.menu :who_we_are
      #     about.menu :contact_us
      #   end
      def menu(id, content = nil, url_options = {}, html_options = {}, &block)
        menu = Menu.new(self, id, content, url_options, html_options, &block)
        @menus << menu
        
        menu
      end
      
      # Builds the actual html of the menu bar
      def html
        html_options = @html_options.dup
        html_options[:class] = "#{html_options[:class]} #{selected_class}".strip if selected?
        
        content_tag(tag_name, content, html_options)
      end
      
      private
        # Unordered list
        def tag_name
          'ul'
        end
        
        # Generate the html for the menu bar
        def content
          @menus.inject('') {|html, menu| html << menu.html(@menus.last == menu)}
        end
    end
  end
end
