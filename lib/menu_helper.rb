require 'menu_helper/html_element'
require 'menu_helper/menu_bar'
require 'menu_helper/menu'

# Provides a builder for generating html menu bars.  The structure of the
# menus/menu bars is based on lists and should be styled using css. 
module MenuHelper
  # Creates a new first-level menu bar.  This takes the configuration options
  # for the menu bar, followed by html options.  Both of these parameters are
  # optional.
  # 
  # Configuration options:
  # * <tt>:auto_set_ids</tt> - Whether or not to automatically add ids to each
  #   menu/menu bar.  Default is true.
  # * <tt>:attach_active_submenus</tt> - Whether any active sub-menu bar should
  #   be rendered as part of its parent menu.  Default is true.
  # * <tt>:content_for</tt> - The base block name to use when detaching active
  #   submenus.  Default is "menu_bar".  For example, this will render
  #   sub-menu bars to menu_bar_level_2.
  # 
  # == Examples
  # 
  #   menu_bar({}, :id => 'nav', :class => 'pretty') do |main|
  #     main.menu :home
  #     main.menu :about_us do |about_us|
  #       about_us.menu :who_we_are
  #       about_us.menu :what_we_do
  #       about_us.menu :where_we_are
  #       about_us.menu :contact, 'Contact', 'mailto:contact@us.com'
  #     end
  #   end
  # 
  # ...generates the following html if +about_us+ is selected...
  # 
  #   <ul id="nav" class="pretty ui-menubar ui-menubar-1">
  #     <li id="nav-home" class="ui-menubar-menu ui-menubar-menu-1"><a href="/"><span>Home</span></a></li>
  #     <li id="nav-about_us" class="ui-menubar-menu ui-menubar-menu-1 ui-state-active ui-menubar-selected"><a href="/about_us"><span>About Us</span></a>
  #       <ul class="ui-menubar ui-menubar-2 ui-state-active ui-menubar-selected">
  #         <li id="nav-about_us-who_we_are" class="ui-menubar-menu ui-menubar-menu-2"><a href="/about_us/who_we_are"><span>Who We Are</span></a></li>
  #         <li id="nav-about_us-what_we_do" class="ui-menubar-menu ui-menubar-menu-2"><a href="/about_us/what_we_do"><span>What We Do</span></a></li>
  #         <li id="nav-about_us-contact" class="ui-menubar-menu ui-menubar-menu-2"><a href="mailto:contact@us.com"><span>Contact</span></a></li>
  #       </ul>
  #     </li>
  #   </ul>
  # 
  # Submenus can be detached from the original parent menu for greater control
  # over layout.  For example,
  # 
  #   menu_bar({:attach_active_submenus => false}, :id => 'nav') do |main|
  #     main.menu :home
  #     main.menu :about_us do |about_us|
  #       about_us.menu :who_we_are
  #       about_us.menu :what_we_do
  #       about_us.menu :where_we_are
  #     end
  #   end
  #   
  #   <div id="subnav">
  #     <%= yield :menu_bar_level_2 %>
  #   </div>
  # 
  # ...generates the following html if +about_us+ is selected...
  # 
  #   <ul id="nav" class="ui-menubar ui-menubar-1">
  #     <li id="nav-home" class="ui-menubar-menu ui-menubar-menu-1"><a href="/"><span>Home</span></a></li>
  #     <li id="nav-about_us" class="ui-menubar-menu ui-menubar-menu-1 ui-state-active ui-menubar-selected"><a href="/about_us"><span>About Us</span></a></li>
  #   </ul>
  #   
  #   <div id="subnav">
  #     <ul class="ui-menubar ui-menubar-2 ui-state-active ui-menubar-selected">
  #       <li id="nav-about_us-who_we_are" class="ui-menubar-menu ui-menubar-menu-2"><a href="/about_us/who_we_are"><span>Who We Are</span></a></li>
  #       <li id="nav-about_us-what_we_do" class="ui-menubar-menu ui-menubar-menu-2"><a href="/about_us/what_we_do"><span>What We Do</span></a></li>
  #       <li id="nav-about_us-contact" class="ui-menubar-menu ui-menubar-menu-2"><a href="mailto:contact@us.com"><span>Contact</span></a></li>
  #     </ul>
  #   </div>
  # 
  # == Menu Selection
  # 
  # The currently selected menu is based on the current page that is displayed
  # to the user.  If the url that the menu links to is the same as the
  # current page, then that menu will be selected.  This menu uses
  # ActionView::Helpers::UrlHelper#current_page? to determine whether or not
  # it is the currently selected menu.
  # 
  # If the menu that is selected is nested within another menu, then those
  # menus will be selected as well.
  # 
  # A "selected" menu/menu bar is indicated by an additional css class that is
  # added to the element.
  # 
  # For example, if a sub-menu like +who_we_are+ is selected, the html
  # generated from the above full example would look like so:
  # 
  #   <ul id="nav" class="pretty ui-menubar ui-menubar-1">
  #     <li id="nav-home" class="ui-menubar-menu ui-menubar-menu-1"><a href="/"><span>Home</span></a></li>
  #     <li id="nav-about_us" class="ui-menubar-menu ui-menubar-menu-1 ui-state-active ui-menubar-selected"><span>About Us</span>
  #       <ul class="menubar menubar-2 menubar-selected">
  #         <li id="nav-about_us-who_we_are" class="ui-menubar-menu ui-menubar-menu-2 ui-state-active ui-menubar-selected"><a href="/about_us/who_we_are"><span>Who We Are</span></a></li>
  #         <li id="nav-about_us-what_we_do" class="ui-menubar-menu ui-menubar-menu-2"><a href="/about_us/what_we_do"><span>What We Do</span></a></li>
  #         <li id="nav-about_us-contact" class="ui-menubar-menu ui-menubar-menu-2"><a href="mailto:contact@us.com"><span>Contact</span></a></li>
  #       </ul>
  #     </li>
  #   </ul>
  # 
  # == Menu Creation
  # 
  # For more information about how menus are created, see the documentation
  # for MenuHelper::MenuBar#menu.
  def menu_bar(options = {}, html_options = {}, &block)
    MenuBar.new(@controller, options, html_options, &block).html
  end
end

ActionController::Base.class_eval do
  helper MenuHelper
end
