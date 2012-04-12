# To change this template, choose Tools | Templates
# and open the template in the editor.
module Linkedin

  class Contact
    #the First name of the contact
    attr_accessor :first_name
    #the last name of the contact
    attr_accessor :last_name
    #the linkedin job title
    attr_accessor :title
    #the location of the contact
    attr_accessor :location
    #the country of the contact
    attr_accessor :country
    #the domain for which the contact belongs
    attr_accessor :industry
    #the entire profile of the contact
    attr_accessor :profile

    #Array of hash containing its past job companies and job profile
    #Example
    #  [
    #    [0] {
    #          :past_title => "Intern",
    #        :past_company => "Sungard"
    #        },
    #    [1] {
    #          :past_title => "Software Developer",
    #        :past_company => "Microsoft"
    #        }
    #  ]

    attr_accessor :past_companies
    #Array of hash containing its current job companies and job profile
    #Example
    #  [
    #    [0] {
    #          :current_title => "Intern",
    #        :current_company => "Sungard"
    #        },
    #    [1] {
    #          :current_title => "Software Developer",
    #        :current_company => "Microsoft"
    #        }
    #  ]
    attr_accessor :current_companies

    attr_accessor :linkedin_url

    attr_accessor :profile
  
    def initialize(node=[])
      unless node.class==Array
        @first_name=get_first_name(node)
        @last_name=get_last_name(node)
        @title=get_title(node)
        @location=get_location(node)
        @country=get_country(node)
        @industry=get_industry(node)
        @current_companies=get_current_companies node
        @past_companies=get_past_companies node
        @linkedin_url=get_linkedin_url node
      end
    end
    #page is a Nokogiri::XML node of the profile page
    #returns object of Linkedin::Profile
    def get_profile page,url
      @profile=Linkedin::Profile.new(page,url)
    end

    private

    def get_first_name node
      return node.at(".given-name").text.strip if node.search(".given-name").first
    end

    def get_last_name node
      return node.at(".family-name").text.strip if node.search(".family-name").first
    end

    def get_title node
      return node.at(".title").text.gsub(/\s+/, " ").strip if node.search(".title").first
    end

    def get_location node
      return node.at(".location").text.split(",").first.strip if node.search(".location").first

    end

    def get_country node
      return node.at(".location").text.split(",").last.strip if node.search(".location").first

    end

    def get_industry node
      return node.at(".industry").text.strip if node.search(".industry").first
    end

    def get_linkedin_url node
      node.at("h2/strong/a").attributes["href"]
    end

    def get_current_companies node
      current_cs=[]
      if node.search(".current-content").first
        node.at(".current-content").text.split(",").each do |content|
          title,company=content.split(" at ")
          company=company.gsub(/\s+/, " ").strip if company
          title=title.gsub(/\s+/, " ").strip if title
          current_company={:current_company=>company,:current_title=> title}
          current_cs<<current_company
        end
        return current_cs
      end
    end

    def get_past_companies node
      past_cs=[]
      if node.search(".past-content").first
        node.at(".past-content").text.split(",").each do |content|
          title,company=content.split(" at ")
          company=company.gsub(/\s+/, " ").strip if company
          title=title.gsub(/\s+/, " ").strip if title
          past_company={:past_company=>company,:past_title=> title }
          past_cs<<past_company
        end
        return past_cs
      end
    end

  end

end
