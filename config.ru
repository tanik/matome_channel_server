# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

map '/backend' do
  run Rails.application
end
