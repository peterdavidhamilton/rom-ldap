# frozen_string_literal: true

if ENV['DEBUG']
  # rubocop:disable Lint/SuppressedException
  begin
    require 'pry-byebug'
  rescue LoadError
  end
  # rubocop:enable Lint/SuppressedException
end

require 'bundler/gem_tasks'

task default: [:spec]
