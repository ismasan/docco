# frozen_string_literal: true

# Find the rake file relative to this file
rakefile = File.expand_path("tasks.rake", __dir__)

# Load it only if Rake is available
if defined?(Rake)
  load rakefile
else
  warn "[my_gem] Rake not loaded; skipping task definitions"
end
