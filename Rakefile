# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require_relative "lib/tree_view/release_check"

RSpec::Core::RakeTask.new(:spec)

namespace :release do
  desc "Verify version, changelog, package, and tag consistency for a release"
  task :check do
    TreeView::ReleaseCheck.run!
  end
end

task default: :spec
