require 'spec_helper'
require 'linkedin-scraper'


describe Linkedin::Profile do
  before(:all) { @profile = Linkedin::Profile.get_profile("http://www.linkedin.com/in/jgrevich") }
  
  describe "::get_profile" do
    it "Create an instance of profile class" do
      expect(@profile).to be_instance_of Linkedin::Profile
    end    
  end

  describe ".first_name" do
    it 'returns the first name of the profile' do
      expect(@profile.first_name).to eq "Justin"
    end
  end

  describe ".last_name" do
    it 'returns the last name of the profile' do
      expect(@profile.last_name).to eq "Grevich"
    end
  end
  
  describe ".name" do
    it 'returns the first and last name of the profile' do
      expect(@profile.name).to eq "Justin Grevich"
    end
  end

  describe ".summary" do
    it 'returns the summary of the profile' do
      expect(@profile.summary.include?("I am a web developer and systems administrator")).to eq true
    end
  end
  
end