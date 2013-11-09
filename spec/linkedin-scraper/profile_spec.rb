require 'spec_helper'
require 'linkedin-scraper'

describe Linkedin::Profile do


  before(:all) do
    @page = Nokogiri::HTML(File.open('spec/fixtures/jgrevich.html', 'r') { |f| f.read })
    @profile = Linkedin::Profile.new('http://www.linkedin.com/in/jgrevich')
  end

  describe '.get_profile' do
    it 'Create an instance of Linkedin::Profile class' do
      expect(@profile).to be_instance_of Linkedin::Profile
    end
  end

  describe '#first_name' do
    it 'returns the first name of the profile' do
      expect(@profile.first_name).to eq 'Justin'
    end
  end

  describe '#last_name' do
    it 'returns the last name of the profile' do
      expect(@profile.last_name).to eq 'Grevich'
    end
  end

  describe '#title' do
    it 'returns the title of the profile' do
      expect(@profile.title).to eq 'Presidential Innovation Fellow'
    end
  end

  describe '#location' do
    it 'returns the location of the profile' do
      expect(@profile.location).to eq 'Washington'
    end
  end

  describe '#country' do
    it 'returns the country of the profile' do
      expect(@profile.country).to eq 'District Of Columbia'
    end
  end

  describe '#industry' do
    it 'returns the industry of the profile' do
      expect(@profile.industry).to eq 'Information Technology and Services'
    end
  end

  describe '#summary' do
    it 'returns the summary of the profile' do
      expect(@profile.summary).to match(/Justin Grevich is a Presidential Innovation Fellow working/)
    end
  end

  describe '#picture' do
    it 'returns the picture url of the profile' do
      expect(@profile.picture).to eq 'http://m.c.lnkd.licdn.com/mpr/pub/image-1OSOQPrarAEIMksx5uUyhfRUO9zb6R4JjbULhhrDOMFS6dtV1OSLWbcaOK9b92S3rlE9/justin-grevich.jpg'
    end
  end

  describe '#skills' do
    it 'returns the array of skills of the profile' do
      skills = ['Ruby', 'Ruby on Rails', 'Web Development', 'Web Applications', 'CSS3', 'HTML 5', 'Shell Scripting', 'Python', 'Chef', 'Git', 'Subversion', 'JavaScript', 'Rspec', 'jQuery', 'Capistrano', 'Sinatra', 'CoffeeScript', 'Haml', 'Standards Compliance', 'MySQL', 'PostgreSQL', 'Solr', 'Sphinx', 'Heroku', 'Amazon Web Services (AWS)', 'Information Security', 'Vulnerability Assessment', 'SAN', 'ZFS', 'Backup Solutions', 'SaaS', 'System Administration', 'Project Management', 'Linux', 'Troubleshooting', 'Network Security', 'OS X', 'Bash', 'Cloud Computing', 'Web Design', 'MongoDB', 'Z-Wave', 'Home Automation']
      expect(@profile.skills).to include(*skills)
    end
  end

  describe '#past_companies' do
    it 'returns an array of hashes of past companies with its details' do
      @profile.past_companies
    end
  end

  describe '#current_companies' do
    it 'returns an array of hashes of current companies with its details' do
      @profile.current_companies
    end
  end

  describe '#education' do
    it 'returns the array of hashes of education with details' do
      @profile.education
    end
  end

  describe '#websites' do
    it 'returns the array of websites' do
      @profile.websites
    end
  end

  describe '#groups' do
    it 'returns the array of hashes of groups with details' do
      @profile.groups
    end
  end

  describe '#name' do
    it 'returns the first and last name of the profile' do
      expect(@profile.name).to eq 'Justin Grevich'
    end
  end

  describe '#organizations' do
    it 'returns an array of organization hashes for the profile' do
      expect(@profile.organizations.class).to eq Array
      expect(@profile.organizations.first[:name]).to eq 'San Diego Ruby'
    end
  end

  describe '#languages' do
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

  end # describe '.languages' do

  describe '#recommended_visitors' do
    it 'returns the array of hashes of recommended visitors' do
      @profile.recommended_visitors
    end
  end

  describe '#certifications' do
    it 'returns the array of hashes of certifications' do
      @profile.certifications
    end
  end

  describe '#to_json' do
    it 'returns the json format of the profile' do
      @profile.to_json
    end
  end

end
