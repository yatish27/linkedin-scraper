USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac FireFox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]
module Linkedin
  class Profile    
    #the First name of the contact
    attr_accessor :first_name,:last_name,:title,:location,:country,
                  :industry, :linkedin_url,:recommended_visitors,:profile,
                  :page


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
    #url of the profile


    def initialize(page,url)   
      @first_name=get_first_name(page)
      @last_name=get_last_name(page)
      @title=get_title(page)
      @location=get_location(page)
      @country=get_country(page)
      @industry=get_industry(page)
      @current_companies=get_current_companies page
      @past_companies=get_past_companies page
      @recommended_visitors=get_recommended_visitors page
      @linkedin_url=url
    end
    #returns:nil if it gives a 404 request
    def self.get_profile url
      begin
        @agent=Mechanize.new
        @agent.user_agent_alias = USER_AGENTS.sample
        @agent.max_history = 0
        @page=@agent.get url
        return Linkedin::Profile.new(@page, url)
      rescue=>e
        puts e
      end
    end

    private

    def get_first_name page
      return page.at(".given-name").text.strip if page.search(".given-name").first
    end

    def get_last_name page
      return page.at(".family-name").text.strip if page.search(".family-name").first
    end

    def get_title page
      return page.at(".headline-title").text.gsub(/\s+/, " ").strip if page.search(".headline-title").first
    end

    def get_location page
      return page.at(".locality").text.split(",").first.strip if page.search(".locality").first
    end

    def get_country page
      return page.at(".locality").text.split(",").last.strip if page.search(".locality").first
    end

    def get_industry page
      return page.at(".industry").text.gsub(/\s+/, " ").strip if page.search(".industry").first
    end

    def get_past_companies page
      past_cs=[]
      if page.search(".past").first
        page.search(".past").search("li").each do |past_company|
          title,company=past_company.text.strip.split(" at ")
          company=company.gsub(/\s+/, " ").strip if company
          title=title.gsub(/\s+/, " ").strip if title
          past_company={:past_company=>company,:past_title=> title}
          past_cs<<past_company
        end
        return past_cs
      end
    end

    def get_current_companies page
      current_cs=[]
      if page.search(".current").first
        page.search(".current").search("li").each do |past_company|
          title,company=past_company.text.strip.split(" at ")
          company=company.gsub(/\s+/, " ").strip if company
          title=title.gsub(/\s+/, " ").strip if title
          current_company={:current_company=>company,:current_title=> title}
          current_cs<<current_company
        end
        return current_cs
      end
    end

    def get_recommended_visitors  page
      recommended_vs=[]
      if page.search(".browsemap").first
        page.at(".browsemap").at("ul").search("li").each do |visitor|
          v={}
          v[:link]=visitor.at('a').attributes["href"]
          v[:name]=visitor.at('a').text
          v[:title]=visitor.at('.headline').text.split(" at ").first
          v[:company]=visitor.at('.headline').text.split(" at ").last
          recommended_vs<<v
        end
        return recommended_vs
      end
      
    end
  end
end
