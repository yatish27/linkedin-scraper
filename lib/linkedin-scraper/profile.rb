# -*- coding: utf-8 -*-
module Linkedin
  class Profile

    USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac FireFox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]

    attr_accessor :first_name, :last_name, :title, :location, :country, :summary, :industry, :picture, :linkedin_url, :recommended_visitors, :page

    attr_accessor :education

    attr_accessor :websites

    attr_accessor :groups

    attr_accessor :past_companies

    attr_accessor :current_companies

    attr_accessor :skills

    def initialize(page,url)
      @first_name           = get_first_name(page)
      @last_name            = get_last_name(page)
      @title                = get_title(page)
      @location             = get_location(page)
      @country              = get_country(page)
      @summary              = get_summary(page)
      @industry             = get_industry(page)
      @picture              = get_picture(page)
      @current_companies    = get_current_companies(page)
      @past_companies       = get_past_companies(page)
      @recommended_visitors = get_recommended_visitors(page)
      @education            = get_education(page)
      @linkedin_url         = url
      @websites             = get_websites(page)
      @groups               = get_groups(page)
      @skills               = get_skills(page)
      @page                 = page
    end
    #returns:nil if it gives a 404 request
    
    
    
    def self.get_profile(url)
      begin
        @agent = Mechanize.new
        @agent.user_agent_alias = USER_AGENTS.sample
        @agent.max_history = 0
        page = @agent.get(url)
        return Linkedin::Profile.new(page, url)
      rescue=>e
        puts e
      end
    end

    def get_skills(page)
      page.search('.skills-section.skill-pill').map{|skill|skill.text.strip if skill.text}
    end

    def get_company_url(node)
      result={}
      if node.at("h4/strong/a")
        link = node.at("h4/strong/a")["href"]
        @agent = Mechanize.new
        @agent.user_agent_alias = USER_AGENTS.sample
        @agent.max_history = 0
        page = @agent.get("http://www.linkedin.com"+link)
        result[:linkedin_company_url] = "http://www.linkedin.com"+link
        result[:url] = page.at(".basic-info/div/dl/dd/a").text if page.at(".basic-info/div/dl/dd/a")
        node_2 = page.at(".basic-info").at(".content.inner-mod")
        node_2.search("dd").zip(node_2.search("dt")).each do |value,title|
          result[title.text.gsub(" ","_").downcase.to_sym] = value.text.strip
        end
        result[:address] = page.at(".vcard.hq").at(".adr").text.gsub("\n"," ").strip if page.at(".vcard.hq")
      end
      result
    end

    private

    def get_first_name(page)
      return page.at(".given-name").text.strip if page.search(".given-name").first
    end

    def get_last_name(page)
      return page.at(".family-name").text.strip if page.search(".family-name").first
    end

    def get_title(page)
      return page.at(".headline-title").text.gsub(/\s+/, " ").strip if page.search(".headline-title").first
    end

    def get_location(page)
      return page.at(".locality").text.split(",").first.strip if page.search(".locality").first
    end

    def get_country(page)
      return page.at(".locality").text.split(",").last.strip if page.search(".locality").first
    end

    def get_summary(page)
      return page.at(".summary.description").text.gsub(/\s+|\n/, " ").strip if page.at(".summary.description")
    end

    def get_industry(page)
      return page.at(".industry").text.gsub(/\s+/, " ").strip if page.search(".industry").first
    end

    def get_picture(page)
      return page.at("#profile-picture/img.photo").attributes['src'].value.strip if page.search("#profile-picture/img.photo").first
    end

    def get_past_companies(page)
      past_cs=[]
      if page.search(".position.experience.vevent.vcard.summary-past").first
        page.search(".position.experience.vevent.vcard.summary-past").each do |past_company|
          result = get_company_url past_company
          url = result[:url]
          title = past_company.at("h3").text.gsub(/\s+|\n/, " ").strip if past_company.at("h3")
          company = past_company.at("h4").text.gsub(/\s+|\n/, " ").strip if past_company.at("h4")
          description = past_company.at(".description.past-position").text.gsub(/\s+|\n/, " ").strip if past_company.at(".description.past-position")
          p_company = {:past_company=>company,:past_title=> title,:past_company_website=>url,:description=>description}
          p_company = p_company.merge(result)
          past_cs << p_company
        end
        return past_cs
      end
    end

    def get_current_companies(page)
      current_cs = []
      if page.search(".position.experience.vevent.vcard.summary-current").first
        page.search(".position.experience.vevent.vcard.summary-current").each do |current_company|
          result = get_company_url current_company
          url = result[:url]
          title = current_company.at("h3").text.gsub(/\s+|\n/, " ").strip if current_company.at("h3")
          company = current_company.at("h4").text.gsub(/\s+|\n/, " ").strip if current_company.at("h4")
          description = current_company.at(".description.current-position").text.gsub(/\s+|\n/, " ").strip if current_company.at(".description.current-position")
          current_company = {:current_company=>company,:current_title=> title,:current_company_url=>url,:description=>description}
          current_cs << current_company.merge(result)
        end
      if page.search(".background-experience").first
        page.search(".background-experience").each do |current_company|
          result = get_company_url current_company
          url = result[:url]
          title = current_company.at("h4").text.gsub(/\s+|\n/, " ").strip if current_company.at("h4")
          company = current_company.at("h5").text.gsub(/\s+|\n/, " ").strip if current_company.at("h5")
          description = current_company.at(".description").text.gsub(/\s+|\n/, " ").strip if current_company.at(".description.current-position")
          current_company = {:current_company=>company,:current_title=> title,:current_company_url=>url,:description=>description}
          current_cs << current_company.merge(result)          
        end
        return current_cs
      end
    end

    def get_education(page)
      education=[]
      if page.search(".position.education.vevent.vcard").first
        page.search(".position.education.vevent.vcard").each do |item|
          name   = item.at("h3").text.gsub(/\s+|\n/, " ").strip if item.at("h3")
          desc   = item.at("h4").text.gsub(/\s+|\n/, " ").strip if item.at("h4")
          period = item.at(".period").text.gsub(/\s+|\n/, " ").strip if item.at(".period")
          edu = {:name => name,:description => desc,:period => period}
          education << edu
        end
        return education
      end
    end

    def get_websites(page)
      websites=[]
      if page.search(".website").first
        page.search(".website").each do |site|
          url = site.at("a")["href"]
          url = "http://www.linkedin.com"+url
          url = CGI.parse(URI.parse(url).query)["url"]
          websites << url
        end
        return websites.flatten!
      end
    end

    def get_groups(page)
      groups = []
      if page.search(".group-data").first
        page.search(".group-data").each do |item|
          name = item.text.gsub(/\s+|\n/, " ").strip
          link = "http://www.linkedin.com"+item.at("a")["href"]
          groups << {:name=>name,:link=>link}
        end
        return groups
      end
    end

    def get_recommended_visitors(page)
      recommended_vs=[]
      if page.search(".browsemap").first
        page.at(".browsemap").at("ul").search("li").each do |visitor|
          v = {}
          v[:link]    = visitor.at('a')["href"]
          v[:name]    = visitor.at('strong/a').text
          v[:title]   = visitor.at('.headline').text.gsub("..."," ").split(" at ").first
          v[:company] = visitor.at('.headline').text.gsub("..."," ").split(" at ")[1]
          recommended_vs << v
        end
        return recommended_vs
      end
    end
  end
end
