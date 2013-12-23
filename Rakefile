require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

RSpec::Core::RakeTask.new
YARD::Rake::YardocTask.new
Yardstick::Rake::Verify.new
Yardstick::Rake::Measurement.new

task :default => :spec
task :doc => :yard
task :test => :spec
