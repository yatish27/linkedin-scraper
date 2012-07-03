module Linkedin

  class Contact
    attr_accessor :first_name, :last_name, :title, :location, :country, :industry, :current_companies, :linkedin_url
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

    # As we are finding information from node all getters and setters should be defined on node
    # For eg. node.first_name
    def initialize(node = [])
      unless node.class == Array
        #why to call the method if node doesn't contain .given-name
        @first_name = get_first_name node if node.search(".given-name").first
        @last_name = get_last_name node if node.search(".family-name").first
        @title = get_title node if node.search(".title").first
        @location = get_location node if node.search(".location").first
        @country = get_country node if node.search(".location").first
        @industry = get_industry node if node.search(".industry").first
        @current_companies = get_current_companies node
        @past_companies = get_past_companies node
        @linkedin_url = get_linkedin_url node
      end
    end
    #page is a Nokogiri::XML node of the profile page
    #returns object of Linkedin::Profile
    def get_profile page,url
      @profile=Linkedin::Profile.new(page,url)
    end

    private

    def get_dynamic(node_at, modifier)
      #node_at will change each time
      # #modifier will contain how to manipulate text, for eg; strip or gsub etc;
      at(node_at).text.#{modifier}
    end

    def get_first_name node
       node.at(".given-name").text.strip
    end

    def get_last_name node
       node.at(".family-name").text.strip
    end

    def get_title node
       node.at(".title").text.gsub(/\s+/, " ").strip
    end

    def get_location node
       node.at(".location").text.split(",").first.strip

    end

    def get_country node
       node.at(".location").text.split(",").last.strip

    end

    def get_industry node
       node.at(".industry").text.strip
    end

    def get_linkedin_url node
      node.at("h2/strong/a").attributes["href"]
    end

    def get_current_companies node
      current_cs = []
      if node.search(".current-content").first
        node.at(".current-content").text.split(",").each do |content|
          title, company = content.split(" at ")
          company = company.gsub(/\s+/, " ").strip if company
          title = title.gsub(/\s+/, " ").strip if title
          current_company = {:current_company => company, :current_title => title}
          current_cs << current_company
        end
        current_cs
      end
    end

    def get_past_companies node
      past_cs=[]
      if node.search(".past-content").first
        node.at(".past-content").text.split(",").each do |content|
          title,company = content.split(" at ")
          company = company.gsub(/\s+/, " ").strip if company
          title = title.gsub(/\s+/, " ").strip if title
          past_company = {:past_company => company, :past_title => title }
          past_cs << past_company
        end
        past_cs
      end
    end
  end
end
end
