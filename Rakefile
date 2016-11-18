require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

APP_RAKEFILE = File.expand_path("../test/sample/Rakefile", __FILE__)
load "rails/tasks/engine.rake"

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: [:test, :rubocop]
