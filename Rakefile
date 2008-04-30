# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/timeliner.rb'

Hoe.new('timeliner', Timeliner::VERSION) do |p|
  # rubyforge_name = 'timelinerx' # if different than lowercase project name
  p.developer('Chad Woolley', 'thewoolleyman@gmail.com')
end

desc "Run Specs"
task :spec do
  system("spec **/*_spec.rb") || raise("Specs Failed!")
end

desc "Update the manifest"
task :update_manifest do
  system('rake diff_manifest | patch -p0 Manifest.txt')
end
