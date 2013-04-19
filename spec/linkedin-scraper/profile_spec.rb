require 'spec_helper'
require 'linkedin-scraper'


describe Linkedin::Profile do
  describe "::get_profile" do
    it "Create an instance of profile class and populate it with all details" do
      @profile = Linkedin::Profile.get_profile("http://www.linkedin.com/in/jeffweiner08")
      @profile.first_name.should == "Jeff"
      #other parameters may change with time
    end
  end
end
