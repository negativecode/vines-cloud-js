# encoding: UTF-8

require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'coffee-script'
require 'uglifier'

CLOBBER.include('pkg', 'vines.js', 'vines.min.js')

desc 'Build distributable packages'
task :build => :assets do
  # create package task after assets are generated so they're included in FileList
  Rake::PackageTask.new('vines-cloud-js', '0.2.0') do |pkg|
    pkg.package_files = FileList['LICENSE', 'README.md', 'vines.js', 'vines.min.js', 'examples/*']
    pkg.need_zip = true
  end
  Rake::Task['package'].invoke
end

desc 'Compile and minimize web assets'
task :assets do
  assets = %w[request resource query channel pubsub app apps users storage vines]
  coffee = assets.inject('') do |sum, name|
    sum + File.read("src/#{name}.js.coffee")
  end
  js = File.read('src/strophe.js') + CoffeeScript.compile(coffee)
  File.open('vines.min.js', 'w') {|f| f.write(Uglifier.compile(js)) }
  File.open('vines.js', 'w') {|f| f.write(js) }
end

task :default => [:clobber, :build]
