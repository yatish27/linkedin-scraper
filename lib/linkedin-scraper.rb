require "linkedin-scraper/version"
require "rubygems"
require "mechanize"
Dir["#{File.expand_path(File.dirname(__FILE__))}/linkedin-scraper/*.rb"].each {|file| require file }



