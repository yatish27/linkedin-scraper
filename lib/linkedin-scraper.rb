require "rubygems"
require "mechanize"
require "cgi"
require "net/http"
require "random_user_agent"
Dir["#{File.expand_path(File.dirname(__FILE__))}/linkedin-scraper/*.rb"].each { |file| require file }
