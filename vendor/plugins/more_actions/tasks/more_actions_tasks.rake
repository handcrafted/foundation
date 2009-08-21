require 'fileutils'

namespace :more_actions do
	desc "Copy javascript & stylesheet asset files into application's public directory"
  task :asset_copy do
    copy_asset('stylesheets')
    copy_asset('javascripts')
  end
end

def copy_asset(type)
  src_dir = File.join(File.dirname(__FILE__), '../assets', type)
  dest_dir = File.join(RAILS_ROOT, 'public', type)

  Dir.glob("#{src_dir}/*.*").each do |f|
    FileUtils.cp f, dest_dir, :verbose => true
  end
end