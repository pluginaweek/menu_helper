require 'menu_helper/html_element'
require 'menu_helper/menu_bar'
require 'menu_helper/menu'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # Provides a builder for generating html menubars.  The structure of the
    # menubars/menus is based on lists and should be styled using css. 
    module MenuHelper
      # Creates a new 1st-level menu bar.  The first parameter is the menubar's
      # configuration options.  The second parameter is the menubar's html
      # options.  Both of these parameters are optional.
      # 
      # Configuration options:
      # * <tt>auto_set_id</tt> - Whether or not to automatically add ids to each menu.
      # 
      # Examples:
      #   menu_bar {}, :id => 'menus', :class => 'pretty' do |main|
      #     main.menu :home
      #     main.menu :about_us do |about_us|
      #       about_us.who_we_are
      #       about_us.what_we_do
      #       about_us.where_we_are
      #       about_us.contact, 'Contact', 'mailto:contact@us.com'
      #     end
      #   end
      #   #=>
      #   <ul id="menus" class="pretty">
      #     <li id="about_us">About Us
      #       <ul id="about_us_menubar">
      #         <li id="who_we_are"><a href="/about_us/who_we_are">Who We Are</a></li>
      #         <li id="what_we_do"><a href="/about_us/what_we_do">What We Do</a></li>
      #         <li id="contact"><a href="mailto:contact@us.com">Contact</a></li>
      #       </ul>
      #     </li>
      #   </ul>
      # 
      # == Menu Selection
      # 
      # The currently selected menu is based on the current page that the user
      # is currently on.  If the url that the menu links to is the same as the
      # current page, then that menu will be selected.  This menu uses
      # ActionView::Helpers::UrlHelper#current_page? to determine whether or not
      # it is the currently selected menu.
      # 
      # If the menu that is selected is nested within another menu, then those
      # menus will be selected as well.
      # 
      # A "selected" menu is indicated by an additional class html attribute
      # that is added to the list item.
      # 
      # For example, if a submenu is selected, the html generated from the
      # above full example would look like so:
      # 
      #   <ul id="menus" class="pretty">
      #     <li id="about_us" class="selected">About Us
      #       <ul id="about_us_menubar">
      #         <li id="who_we_are" class="selected"><a href="/about_us/who_we_are">Who We Are</a></li>
      #         <li id="what_we_do"><a href="/about_us/what_we_do">What We Do</a></li>
      #         <li id="contact"><a href="mailto:contact@us.com">Contact</a></li>
      #       </ul>
      #     </li>
      #   </ul>
      # 
      # == Menu Creation
      # 
      # For more information about how menus are created, see the documentation
      # for MenuBar#menu.
      def menu_bar(*args, &block)
        MenuBar.new(@controller, *args, &block).build
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::MenuHelper
end
