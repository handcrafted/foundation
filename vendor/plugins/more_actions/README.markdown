#More Actions
 
##Introduction
 
More Actions is a plugin to quickly build a table of ActiveRecord objects with full multi-object actions, similar to how Gmail handles mail with their "more actions" drop down.  It is built with support for will_paginate and it uses jquery to do the json work - it is fully degradable if js is turned off.
 
If you have questions email us at [hello@gethandcrafted.com](mailto:hello@gethandcrafted.com).

##Installation

You can install MoreActions as a standard rails plugin:
  
    script/plugin install git://github.com/handcrafted/more_actions.git

##Setup
 
The first step is to import the javascript and css

    rake more_actions:asset_copy

Then you can add the more_actions call to your controller

    class PostsController < ApplicationController
      more_actions Post, {:promote => "Promote to Admin"}

Add support for the manage action in your route resource

    map.resources :posts, :collection => {:manage => :post}
    
Last, just add the call to resources_table in your view

    <%= resources_table @posts %>

See the [wiki](http://wiki.github.com/handcrafted/more_actions) for more the full options.

##Screenshots

![Screenshot with no data](http://cloud.github.com/downloads/handcrafted/more_actions/More_actions_-_no_resources.png)

![Screenshot with data](http://cloud.github.com/downloads/handcrafted/more_actions/More_actions_-_copy.png)

See the [wiki](http://wiki.github.com/handcrafted/more_actions) for more details.

##Credits
 
Created by [Josh Owens](http://josh.the-owens.com/ "Josh Owens | Freelance Ruby on Rails Developer") and [Adam Stacoviak](http://www.adamstacoviak.com/ "Adam Stacoviak | Freelance Ruby on Rails Front-end Developer"). Josh and Adam are co-founders of [Handcrafted](http://gethandcrafted.com/ "Handcrafted &ndash; Ruby on Rails Products and Open Source Software"), a Ruby on Rails Products and Open Source Software Company.
 
A big thanks to Gmail for pioneering the interface we so love for quick email management!

##TODO

* Fix json remove support
* Add sortable headers
* Add js callback methods for before/after the manage action call
* Add more tests and documentation