# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

APP_RAKEFILE = File.expand_path("test/sample/Rakefile", __dir__)
load "rails/tasks/engine.rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: %i[test standard]

namespace :app do
  task :yarn_install do
    Dir.chdir("test/sample") do
      sh "yarn install"
    end
  end

  task :yarn_install_frozen do
    Dir.chdir("test/sample") do
      sh "yarn install --frozen-lockfile"
    end
  end
end
