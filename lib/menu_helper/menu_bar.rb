module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module MenuHelper #:nodoc:
      # Represents a group of menus.  A menu bar can either be the main menu
      # bar or a menu bar nested within a menu.
      class MenuBar < HtmlElement
        # The menus within this menu bar
        attr_reader :menus
        
        def initialize(request_controller, options = {}, html_options = {}, parent_menu = nil) #:nodoc:
          super(html_options)
          
          options.assert_valid_keys(:auto_set_ids)
          options.reverse_merge!(:auto_set_ids => true)
          @options = options
          @request_controller = request_controller
          @parent_menu = parent_menu
          
          @menus = []
          
          if @parent_menu
            self[:id] ||= "#{@parent_menu[:id]}_menubar"
          else
            self[:id] ||= 'menubar'
          end
          
          yield self if block_given?
        end
        
        # Creates a new menu in this bar with the given id.  The content
        # within the menu is, by default, set to a humanized version of the id.
        # 
        # == URLs with routes
        # 
        # If you have named routes setup in the application, the menu attempts
        # to automatically figure out what URL you're trying to link to.  It
        # does this by looking at the id of the menu and the id of its parent.
        # 
        # For example, a menu_bar with the id 'home' and a menu with the id
        # 'contact_us' will attempt to look for the following named routes as
        # the URL to link to (in order of priority):
        # 1. contact_us_url
        # 2. home_contact_us_url
        # 
        # Example routes.rb:
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
        # Example menubar:
        #   menu :home do |home|
        #     menu :about_us
        #       #=> Links to about_us_url
        #     menu :search
        #       #=> Links to home_search_url
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
        #   menu :contact, 'Contact Us', {}, :controller => 'about_us'
        # 
        # Examples:
        #   menu :home do |home|
        #     menu :about, 'About Us', :action => 'about_us'
        #       #=> Links to {:controller => 'home', :action => 'about_us'}
        #     menu :who_we_are
        #       #=> Links to {:controller => 'home', :action => 'who_we_are'}
        #     menu :contact_us, 'Contact Us', :controller => 'contact', :action => 'index'
        #       #=> Links to {:controller => 'contact', :action => 'index'}
        #     menu :search
        #       #=> Links to {:controller => 'search'}
        #   end
        # 
        # You can also link to an explicit URL like so:
        #   menu :search, 'http://www.google.com'
        # 
        # == Turning off links
        # 
        # If you don't want a menu to link to a URL, you can turn off linking like so:
        #   menu :contact_us, 'Contact Us', {}, :auto_link => false
        # 
        # == Defining content and html attributes
        # 
        # By default, the content within a menu will be set as a humanized
        # version of the menu's id.  Examples of menus which customize the
        # content and/or html attributes are below:
        # 
        #   menu :contact
        #     #=> <li id="contact"><a href="/contact">Contact</a></li>
        #   menu :contact, 'Contact Us'
        #     #=> <li id="contact"><a href="/contact">Contact Us</a></li>
        #   menu :contact, :class => 'pretty'
        #     #=> <li id="contact" class="pretty"><a href="/contact">Contact</a></li>
        #   menu :contact, 'Contact Us', :class => 'pretty'
        #     #=> <li id="contact" class="pretty"><a href="/contact">Contact Us</a></li>
        # 
        # == Submenus
        # 
        # Menus can also have their own submenus by passing in a block.  You can
        # create submenus in the same manner that the main menus are created.
        # For example,
        # 
        #   menu :about do |about|
        #     about.menu :who_we_are
        #     about.menu :contact_us
        #   end
        def menu(id, *args, &block)
          menu = Menu.new(id, @request_controller, @parent_menu, *args, &block)
          @menus << menu
          
          menu
        end
        
        # Builds the actual html for the menu bar
        def build
          html = @menus.inject('') do |html, menu|
            html << menu.build(@menus.last == menu)
          end
          
          html.blank? ? html : content_tag('ul', html, @html_options)
        end
      end
    end
  end
end
