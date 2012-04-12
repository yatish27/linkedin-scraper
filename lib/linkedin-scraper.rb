require "linkedin-scraper/version"
require "rubygems"
require "mechanize"
require "awesome_print"

%w(client contact profile).each do |file|
  require File.join(File.dirname(__FILE__), 'linkedin', file)
end


