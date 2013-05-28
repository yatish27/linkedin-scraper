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
  
  describe ".languages" do
    it 'returns an array of languages hashes' do
      expect(@profile.languages.class).to eq Array
    end
    
    context 'with language data' do
      
      it 'returns an array with one language hash' do
        expect(@profile.languages.class).to eq Array
      end
      
      describe 'language hash' do        
        it 'contains the key and value for language name' do
          expect(@profile.languages.first[:language]).to eq 'English'
        end
        
        it 'contains the key and value for language proficiency' do
          expect(@profile.languages.first[:proficiency]).to eq '(Native or bilingual proficiency)'
        end
      end
    
    end # context 'with language data' do
    
  end # describe ".languages" do
  
  describe ".name" do
    it 'returns the first and last name of the profile' do
      expect(@profile.name).to eq "Justin Grevich"
    end
  end
  
end
