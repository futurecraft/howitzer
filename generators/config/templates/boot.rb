require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

if Howitzer.coverage
  SimpleCov.start do
    add_filter do |source_file|
      !source_file.filename.include?('web')
    end
  end
end

Dir[
  './emails/**/*.rb',
  './web/sections/**/*.rb',
  './web/pages/**/*.rb',
  './prerequisites/models/**/*.rb',
  './prerequisites/factory_girl.rb'
].each { |f| require f }

String.send(:include, Howitzer::Utils::StringExtensions)
