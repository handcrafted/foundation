COMPASS CHANGELOG
=================

0.8.5 (July 06, 2009)
---------------------

The Compass::TestCase class now inherits from ActiveSupport::TestCase if it exists.
[Commit](http://github.com/chriseppstein/compass/commit/71d5ae8544d1c5ae49e28dcd6b3768fc39d7f01c)

0.8.4 (July 06, 2009)
---------------------

Fixed a bug in rails integration introduced in 0.8.3.

0.8.3 (July 06, 2009)
---------------------

Note: Compass now depends on the stable release of haml with version 2.2.0 or greater.

### Compass Core

* A new helper function `stylesheet_url(path)` can now be used to refer to assets that are relative to the css directory.
  [Commit](http://github.com/chriseppstein/compass/commit/ff5c8500144272ee2b94271b06cce1690cbbc000).
* Cross browser ellipsis mixin is now available. Use `compass -p ellipsis` to install it into your project since it
  requires some additional assets.
  [Commit](http://github.com/chriseppstein/compass/commit/3d909ceda997bdcde2aec09bd72e646098389e7d).

### Blueprint

* The +colruler mixin now accepts an argument for the color.
  [Commit](http://github.com/chriseppstein/compass/commit/a5393bbb7cd0941ab8add5be188aea1d6f9d4b00)
  by [Thomas Reynolds][tdreyno].

### Extensions

* A bug was fixed related to how javascript installation as part of an extension manifest.
  [Commit](http://github.com/chriseppstein/compass/commit/a5393bbb7cd0941ab8add5be188aea1d6f9d4b00)
  by [dturnbull][dturnbull].
* When installing a file, the :like option can now be set to have it installed into the
  same location as what it is like. E.g. `file 'foo.xml', :like => :css` will install
  the foo.xml file into the top level of the project's css directory.
  [Commit](http://github.com/chriseppstein/compass/commit/21cfce33db81e185ce5517818844a9849b5a836e).

### Configuration
* Setting `http_images_path` to `:relative` is now **deprecated**. Instead, please set `relative_assets` to
  `true`.
  [Commit](http://github.com/chriseppstein/compass/commit/956c437fe9ffaad08b6b34d91b6cfb80d6121a2f).
* New configuration option `http_path` can be used to set the project's path relative to the server's root.
  Defaults to "/". The http paths to images, stylesheets, and javascripts are now assumed to be relative to that
  path but can be overridden using the `http_images_path`, `http_css_path`, `http_javascripts_path`.
  [Commit](http://github.com/chriseppstein/compass/commit/6555ab3952ae37d736d54f43ee7053c2a88f4a69).

### Command Line

* A new command line option `--relative-assets` can be used to cause links to assets generated
  via compass helper functions to be relative to the target css file.
  [Commit](http://github.com/chriseppstein/compass/commit/956c437fe9ffaad08b6b34d91b6cfb80d6121a2f).

0.8.2 (July 04, 2009)
---------------------

Fixed a bug that caused touch to fail on windows due to open files. (Contributor: Joe Wasson)

0.8.1
-----

Fixed some build issues and a bug in the rewritten --watch mode that caused changes to partials to go unnoticed.

0.8.0
-----

### Rails

* image_url() now integrates with the rails asset handling code when
  stylesheets are generated within the rails container.
  **This causes your rails configuration for cache busting and asset hosts
  to be used when generating your stylesheets**. Unfortunately, all
  that code runs within the context of a controller, so the stylesheets
  have to be generated during first request to use this functionality. If you
  need to compile stylesheets offline, use the compass configuration file to set
  the <code>asset_host</code> and <code>asset_cache_buster</code>.
  [Commit](http://github.com/chriseppstein/compass/commit/998168160b11c8702ded0a32820ea15b70d51e83).

* An official Rails template for Compass is now [provided][rails_template].
  [Commit](http://github.com/chriseppstein/compass/commit/f6948d1d58818ef8babce8f8f9d775562d7cd7ef)
  by [Derek Perez][perezd].

### Blueprint

* The Blueprint port has been upgraded to match Blueprint 0.9. The following changes were made as part
  of that project:
  * Removed body margins from blueprint scaffolding by default.
    The old body styles can be reinstated by mixing +blueprint-scaffolding-body into your body selector(s).
    [Commit](http://github.com/chriseppstein/compass/commit/45af89d4c7a396fae5d14fab4ef3bab23bcdfb6a)
    by [Enrico Bianco][enricob].
  * A bug in the calculations affecting the +colborder mixin has been fixed.
    [Commit](http://github.com/chriseppstein/compass/commit/4b33fae5e5c5421580ba536116cb10194f1318d1)
    by [Enrico Bianco][enricob].
    Related [commit](http://github.com/chriseppstein/compass/commit/0a0a14aab597d2ec31ff9d267f6ee8cfad878e10).
  * Blueprint now has inline form support. Mix +blueprint-inline-form into a form selector to make it inline.
    [Commit](http://github.com/chriseppstein/compass/commit/56c745b939c763cfcc5549b54979d48ab1309087)
    by [Enrico Bianco][enricob].
  * Please update the conditional comment that surrounds your IE stylesheet to use "lt IE 8" as the condition
    as these styles are not needed in IE8. New blueprint projects will now use this conditional as their default.
    [Commit](http://github.com/chriseppstein/compass/commit/77f6e02c0ec80d2b6fd19e611ced02be003c98ae)
    by [Enrico Bianco][enricob].
  * Explicitly define image interpolation mode for IE so that images aren't jagged when resizing.
    [Commit](http://github.com/chriseppstein/compass/commit/63075f82db367913efcce5e1d0f5489888e86ca4)
    by [Enrico Bianco][enricob].

* When starting a new project based on Blueprint, a more complete screen.sass file will be
  provided that follows compass best practices instead of matching blueprint css exactly. A
  partials/_base.sass file is provided and already set up for blueprint customization.
  [Commit](http://github.com/chriseppstein/compass/commit/11b6ea14c3ee919711fa4bdce349f88b64b68d51)

* The sizes and borders for form styling can now be altered via mixin arguments.
  [Commit](http://github.com/chriseppstein/compass/commit/b84dd3031b82547cff8e1ef1f85de66d98cd162b)
  by [Thomas Reynolds][tdreyno].

* Grid borders can now be altered via mixin arguments.
  [Commit](http://github.com/chriseppstein/compass/commit/0a0a14aab597d2ec31ff9d267f6ee8cfad878e10)
  by [Thomas Reynolds][tdreyno].

* The reset file for blueprint has moved from compass/reset.sass to blueprint/reset.sass. Please
  update your imports accordingly. Also note that some of the reset mixin names have changed
  (now prefixed with blueprint-*).
  [Commit](http://github.com/chriseppstein/compass/commit/2126240a1a16edacb0a758d782334a9ced5d9116)
  by [Noel Gomez][noel].

### Compass Core

* **Sprites**. A basic sprite mixin is now available. Import compass/utilities/sprites.sass and use the +sprite-img
  mixin to set the background image from a sprite image file. Assumes every sprite in the sprite image
  file has the same dimensions.
  [Commit](http://github.com/chriseppstein/compass/commit/1f21d6309140c009188d350ed911eed5d34bf02e)
  by [Thomas Reynolds][tdreyno].

* **Reset**. The compass reset is now based on [Eric Meyer's reset](http://meyerweb.com/eric/thoughts/2007/05/01/reset-reloaded/).
  which makes no attempt to apply base styles like the blueprint reset does. **Existing compass projects
  will want to change their reset import to point to blueprint/reset.sass** -- which is where the old
  default reset for compass projects now lives -- see the blueprint notes above for more information.
  [Commit](http://github.com/chriseppstein/compass/commit/2126240a1a16edacb0a758d782334a9ced5d9116)
  by [Noel Gomez][noel].

* A bug was fixed in the tag_cloud mixin so that it actually works.
  [Commit](http://github.com/chriseppstein/compass/commit/be5c0ff6731ec5e0cdac73bc47f5603c3db899b5)
  by [Bjørn Arild Mæland][Chrononaut].

### Sass Extensions

* The <code>inline_image(image_path)</code> function can now be used to generate a data url that embeds the image data in
  the generated css file -- avoiding the need for another request.
  This function works like <code>image_url()</code> in that it expects the image to be a path
  relative to the images directory. There are clear advantages and disadvantages to this approach.
  See [Wikipedia](http://en.wikipedia.org/wiki/Data_URI_scheme) for more details.
  NOTE: Neither IE6 nor IE7 support this feature.
  [Commit](http://github.com/chriseppstein/compass/commit/5a015b3824f280af56f1265bf8c3a7c64a252621).

### Configuration

* **Asset Hosts**. You can now configure the asset host(s) used for images via the image_url() function.
  Asset hosts are off unless configured and also off when relative urls are enabled. 
  [Commit](http://github.com/chriseppstein/compass/commit/ef47f3dd9dbfc087de8b12a90f9a82993bbb592e).
  In your compass configuration file, you must define an asset_host algorithm to be used like so:
      # Return the same host for all images:
      asset_host {|path| "http://assets.example.com" }
      # Return a different host based on the image path.
      asset_host do |path|
        "http://assets%d.example.com" % (path.hash % 4)
      end


* **Configurable Cache Buster**. You can now configure the cache buster that gets placed at the end of
  images via the image_url function. This might be useful if you need to coordinate the query string
  or use something other than a timestamp.
  [Commit](http://github.com/chriseppstein/compass/commit/ef47f3dd9dbfc087de8b12a90f9a82993bbb592e)
  Example:
      asset_cache_buster do |path, file|
        "busted=true"
      end

* You can now set/override arbitrary sass options by setting the <code>sass_options</code> configuration property
  to a hash. [Commit](http://github.com/chriseppstein/compass/commit/802bca61741db31da7131c82d31fff45f9323696).

* You can now specify additional import paths to look for sass code outside the project.
  [Commit](http://github.com/chriseppstein/compass/commit/047be06a0a63923846f53849fc220fb4be69513b).
  This can be done in two ways:
    1. By setting <code>additional_import_paths</code> to an array of paths.
    2. By (repeatedly) calling <code>add_import_path(path)</code>

* The compass configuration can now be placed in PROJECT_DIR/.compass/config.rb if you so choose.
  [Commit](http://github.com/chriseppstein/compass/commit/69cf32f70ac79c155198d2dbf96f50856bee9504).


### Command Line

* **Watch Improvements** The watch command was rewritten for robustness and reliability. The most
  important change is that generated css files will be deleted if the originating sass file is removed while
  watching the project. [Commit](http://github.com/chriseppstein/compass/commit/0a232bd922695f6f659fac9f90466745d4425839).

* The images and javascripts directories may now be set via the command line.
  [Commit](http://github.com/chriseppstein/compass/84aec053d0109923ea0208ac0847684cf09cefc1).

* The usage output (-h) of the command-line has been reformatted to make it more readable and understandable.
  [Commit](http://github.com/chriseppstein/compass/f742f26208f4c5c783ba63aa0cc509bb19e06ab9).

* The configuration file being read can now be specified explicitly using the -c option.
  This also affects the output location of the --write-configuration command.
  NOTE: The -c option used to be for writing the configuration file, an infrequently used option.
  [Commit](http://github.com/chriseppstein/compass/d2acd343b899db960c1d3a377e2ee6f58595c6b1).

* You can now install into the current working directory by explicitly setting the command line mode to -i
  and providing no project name.
  [Commit](http://github.com/chriseppstein/compass/f742f26208f4c5c783ba63aa0cc509bb19e06ab9).

### Compass Internals

* Some internal code was reorganized to make managing sass extensions and functions more manageable.

* Some internal code was reorganized to make managing ruby application integration more manageable.

* The compass unit tests were reorganized to separate rails testing from other tests.

* The [Rip Packaging System](http://hellorip.com) is now supported.
  [Commit](http://github.com/chriseppstein/compass/commit/56f36577c7654b93a349f74abf274327df23402b)
  by [Will Farrington](http://github.com/wfarr).

* A [licence is now available](http://github.com/chriseppstein/compass/blob/master/LICENSE.markdown)
  making the copyrights and terms of use clear for people who care about such things.


0.6.14
------

Extracted the css validator to an external gem that is only required if you try to use the validation feature.
This makes the compass gem a lot smaller (0.37MB instead of 4MB). To install the validator:

    sudo gem install chriseppstein-compass-validator --source http://gems.github.com/

0.6.8 thru 0.6.13
-----------------

The compass gem is now built with Jeweler instead of Echoe. No changes to speak of. These versions were bug
fixes and working out the new release process.

0.6.7
-----

Bug fix release.

### Rails

The output_style will no longer be set in the compass.config file. Instead compass will use the runtime rails environment to set a sensible default.

### Command Line

The Sass cache directory will be placed into the sass directory of the project instead of the directory from where the compass command was ran.

### Compass Core

Extracted two new mixins from +horizontal-list.  The new +horizontal-list-container and +horizontal-list-item mixins can be used to build your
horizontal list when you need more control over the selectors (E.g. when working with nested lists).

0.6.6
-----

The Haml project now releases a gem called haml-edge that is built from the haml master branch instead of stable. Compass now depends on this gem and will continue to do so until haml 2.2 is released. This should reduce the number of installation problems that have been encountered by new users.

### Command Line

* Fixed a bug that had broken the --write-configuration (-c) option.
* The --force option will now force recompilation. Useful when the stylesheets don't appear to need a recompile according to the file timestamps.

### Unit tests

* Some unit tests were cleaned up for clarity and to better take advantage of the compass project management facilities.

0.6.5
-----

### Compass Core

Converted all mixins definitions referencing images to use the new sass function <code>image\_url()</code>. The following mixins were affected:

* <code>+pretty-bullets</code>
* <code>+replace-text</code>

The calls to these mixins should now pass a path to the image that is relative to the images directory of the project.

### Command Line

* Required frameworks specified from the command line will now be added into the initial project configuration file.

0.6.4
-----

### Command Line

Added a command line option --install-dir that will emit the directory where compass is installed. Useful for debugging and drilling into the compass examples and libraries.

0.6.3
-----

### Rails

Bug fix: The http_images_path configuration default should be "/images" instead of "/public/images".

### Command Line

These changes, coupled with upcoming changes to Sass result in significantly reduced time spent on compilation for large projects.

* The compass command line will no longer recompile sass files that haven't changed (taking import dependencies into account).
* The compass command line will now respect the -q (quiet) option during compilation. Additionally, the quiet option will be set by default when watching a project for changes.

0.6.2
-----

### Blueprint

Split the push and pull mixins into sub-mixins that separate the common styles from the ones that vary. The generated css when using presentational class names will be smaller as a result. The existing <code>+push</code> and <code>+pull</code> mixins continue to work as expected. The following mixins were added:

    +push-base
    +push-margins
    +pull-base
    +pull-margins

Additonally, the liquid plugin was updated to have a span mixin that matches elsewhere.

### YUI

Added Yahoo's version of the css reset. To use it, mix into the top level of your project:

    @import yui/modules/reset.sass
    +reset

### Rails

* Conditionally defining #blank? on String/NilClass (Erik Bryn <erik.bryn@gmail.com>)
* Set compass environment in plugin based on RAILS_ENV (Lee Nussbaum <wln@scrunch.org>)

0.6.1
-----

Maintenance release that fixes several bugs in the handling of configuration files.

0.6.0
-----

### New Core Functionality: **Patterns**

Patterns give a framework or plugin access to the compass installer framework
to install customizable sass, html as well as image and javascript assets.

A pattern is a folder in the plugin's templates directory. It must
have a manifest file that tells compass what to install and where.
Unlike the project template, a pattern can be stamped out any number of
times.

It is best for pattern stylesheets to only provide example usage to get
the user started. All the core styles for the pattern should be
distributed as part of the framework's stylesheets as mixins to
facilitate easy upgrades and bug fixing on the part of the pattern's
maintainer.

Example Usage:
compass --framework blueprint --pattern buttons

Please read the
[Wiki Page](http://wiki.github.com/chriseppstein/compass/patterns) for more information.

### New Command-line options:

1. <code>--validate</code><br/>
   Validate your project's compiled css. Requires java and probably only works on Mac and Unix.
2. <code>--grid-img [DIMENSIONS]</code><br/>
   Generate a background image to test grid alignment. Dimension is given as
   <column_width>+<gutter_width>. Defaults to 30+10.
3. <code>-p, --pattern PATTERN</code><br/>
   When combined with with the --framework option, will stamp a plugin's pattern named PATTERN.
4. <code>-n, --pattern-name NAME</code><br/>
   When combined with the --pattern option, the pattern that gets stamped out will
   be isolated in subdirectories named NAME.
5. <code>-c, --write-configuration</code><br/>
   Emit a compass configuration file into the current directory, taking any existing configuration
   file and any command line options provided into account. (command line options override
   configuration file options).

### New Sass Functions:

Compass projects can call these sass functions within their sass files, if you find them useful.

1. <code>enumerate(prefix, start, end)</code><br/>
   Generates selectors with a prefix and a numerical ending
   counting from start to end. E.g. enumerate("foo", 1, 3) returns "foo-1, foo-2, foo-3"
2. <code>image_url(path)</code><br/>
   Uses the compass configuration to convert a path relative to the compass
   project directory to a path that is either absolute for serving in an HTTP
   context or that is relative to whatever css file the function was being
   compiled into. In the future, this function may also tap into the rails
   asset host configuration.

### New Compass Core Mixins

1. <code>+float-left</code> & <code>+float-right</code><br/>
   In order to include fixes for IE's double-margin bug universally,
   floats were implemented as a utility mixins. These are available by importing
   compass/utilities/general/float.sass which also imports the clearfix module.
2. <code>+pie-clearfix</code><br/>
   Implementation of the
   [position-is-everything clearfix](http://www.positioniseverything.net/easyclearing.html)
   that uses content :after.

### Blueprint 0.8

The Compass port of Blueprint has been upgraded from 0.7.1 to 0.8.0. The 0.8.0 release
brings many bug fixes and a few backward incompatible changes if you use it's presentational
classnames (you don't do that, do you?). Upgrading to 0.8 is automatic when you upgrade to
compass 0.6.0. The Blueprint team didn't release a detailed changelog for me to point at here.
One of the key features of the release was the inclusion of three new core blueprint plugins
(a.k.a. folders you can copy). These are what prompted the development of the compass patterns
feature and two of them are packaged as patterns:

1. Buttons<br/>
   To install: <code>compass --framework blueprint --pattern buttons</code><br/>
   Then follow your nose.
2. Link Icons<br/>
   To install: <code>compass --framework blueprint --pattern link\_icons</code><br/>
   Then follow your nose.

The third plugin is the RTL (right-to-left) plugin. To use this one, simply import it after the import
of the blueprint grid and your mixins will be redefined to work in a left to right manner. Additionally,
it provides +rtl-typography mixin that works in conjunction with +blueprint-typography and should be mixed
in with it.

Lastly, I've rewrote some of the presentational class name generation code so that it very nearly
matches the blueprint CSS. Please note that they are not 100% the same because we fix some bugs
that are not yet fixed in blueprint-css and we use a different clearfix implementation.

### Bug Fixes

1. A Safari bug related to the +clearfix mixin was resolved.
2. Running the compass command line installer a second time.

### Bugs Introduced

Almost definitely. Please let me know if you encounter any problems and I'll get a patch out

[tdreyno]: http://github.com/tdreyno
[noel]: http://github.com/noel
[enricob]: http://github.com/enricob
[perezd]: http://github.com/perezd
[Chrononaut]: http://github.com/Chrononaut
[rails_template]: http://github.com/chriseppstein/compass/raw/4e7e51e2c5491851f66c77abf3f15194f2f8fb8d/lib/compass/app_integration/rails/templates/compass-install-rails.rb
[dturnbull]: http://github.com/dturnbull
