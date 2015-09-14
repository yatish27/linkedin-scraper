require 'spec_helper'
require 'linkedin_scraper'

describe Linkedin::Profile do
  # This is the HTML of https://www.linkedin.com/in/jeffweiner08
  let(:profile) { Linkedin::Profile.new("file://#{File.absolute_path(File.dirname(__FILE__) + '/../fixtures/jeffweiner08.html')}") }

  describe ".get_profile" do
    it "creates an new instance of Linkedin::Profile" do
      expect(profile).to be_instance_of Linkedin::Profile
    end
  end

  describe "#first_name" do
    it "returns profile's first name" do
      expect(profile.first_name).to eq "Jeff"
    end
  end

  describe '#last_name' do
    it "returns profile's last name" do
      expect(profile.last_name).to eq "Weiner"
    end
  end

  describe '#title' do
    it "returns profile's title" do
      expect(profile.title).to eq "CEO at LinkedIn"
    end
  end

  describe "#location" do
    it "returns profile's location" do
      expect(profile.location).to eq "Mountain View"
    end
  end

  describe "#country" do
    it "returns profile's country or state" do
      expect(profile.country).to eq "California"
    end
  end

  describe '#industry' do
    it "returns list of profile's industries" do
      expect(profile.industry).to eq "Internet"
    end
  end

  describe '#skills' do
    it "returns list of profile's skills" do
      expect(profile.skills).to include("Product Development")
    end
  end

  describe '#websites' do
    it "returns list of profile's websites" do
      expect(profile.websites).to include("http://www.linkedin.com/")
    end
  end

  describe '#groups' do
    it "returns list of profile's groups" do
      p profile.groups
    end
  end

  describe '#name' do
    it 'returns the first and last name of the profile' do
      expect(profile.name).to eq "Jeff Weiner"
    end
  end

  describe '#projects' do
    it 'returns the array of hashes of recommended visitors' do
      expect(profile.projects.class).to eq Array
    end
  end

  describe '#connections' do
    it 'return the number of connections' do
      expect(profile.connections).to eq '500+'
    end
  end

  describe '#recommended_visitors' do
    it 'returns recommended visitors' do
      expect(profile.recommended_visitors.class).to eq Array
    end
  end
end
