# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

begin
  require_relative "lib/docco/tasks"
rescue LoadError
  warn "Skipping docco/tasks — not available in packaged gem"
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
