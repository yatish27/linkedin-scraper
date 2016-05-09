$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
