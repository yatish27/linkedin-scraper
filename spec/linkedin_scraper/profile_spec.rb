# encoding: UTF-8

require 'spec_helper'
require 'linkedin-scraper'

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
      expect(profile.location).to eq "San Francisco Bay Area"
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

    it 'does not return "See less"' do
      expect(profile.skills).not_to include("See less")
    end
  end

  describe '#websites' do
    it "returns list of profile's websites" do
      expect(profile.websites).to include("http://www.linkedin.com/")
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

  describe '#summary' do
    it 'returns the summary of the profile' do
      expect(profile.summary).to eq "Internet executive with over 20 years of experience, including general management of mid to large size organizations, corporate development, product development, business operations, and strategy. Currently CEO at LinkedIn, the web's largest and most powerful network of professionals. Prior to LinkedIn, was an Executive in Residence at Accel Partners and Greylock Partners. Primarily focused on advising the leadership teams of the firm's existing consumer technology portfolio companies while also working closely with the firm’s partners to evaluate new investment opportunities.Previously served in key leadership roles at Yahoo! for over seven years, most recently as the Executive Vice President of Yahoo!'s Network Division managing Yahoo's consumer web product portfolio, including Yahoo's Front Page, Mail, Search, and Media products.Specialties: general management, corporate development, product development, business operations, strategy, product marketing, non-profit governance"
    end
  end

  describe '#recommended_visitors' do
    it 'returns recommended visitors' do
      expect(profile.recommended_visitors.class).to eq Array
    end
  end
end
