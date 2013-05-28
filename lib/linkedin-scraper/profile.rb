# -*- coding: utf-8 -*-
module Linkedin
  class Profile

    USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac FireFox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]

    attr_accessor :certifications, :country, :current_companies, :education, :first_name, :groups, :industry, :languages, :last_name, :linkedin_url, :location, :organizations, :page, :past_companies, :picture, :recommended_visitors, :skills, :summary, :title, :websites

    def initialize(page,url)
      @first_name           = get_first_name(page)
      @last_name            = get_last_name(page)
      @title                = get_title(page)
      @location             = get_location(page)
      @country              = get_country(page)
      @industry             = get_industry(page)
      @picture              = get_picture(page)
      @summary              = get_summary(page)
      @current_companies    = get_current_companies(page)
      @past_companies       = get_past_companies(page)
      @recommended_visitors = get_recommended_visitors(page)
      @education            = get_education(page)
      @languages            = get_languages(page)
      @linkedin_url         = url
      @websites             = get_websites(page)
      @groups               = get_groups(page)
      @certifications       = get_certifications(page)
      @organizations        = get_organizations(page)
      @skills               = get_skills(page)
      @languages            = get_languages(page)
      @page                 = page 
    end
    #returns:nil if it gives a 404 request

    def name
      name = ''
      name += "#{self.first_name} " if self.first_name
      name += self.last_name if self.last_name
      name
    end

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

    private

    def get_certifications(page)
      certifications = []
      # search string to use with Nokogiri
      query = 'ul.certifications li.certification'
      months = 'January|February|March|April|May|June|July|August|September|November|December'
      regex = /(#{months}) (\d{4})/
      
      # if the profile contains cert data
      if page.search(query).first
        
        # loop over each element with cert data
        page.search(query).each do |item|
          item_text = item.text.gsub(/\s+|\n/, " ").strip
          name = item_text.split(" #{item_text.scan(/#{months} \d{4}/)[0]}")[0]
          authority = nil # we need a profile with an example of this and probably will need to use the API to accuratetly get this data
          license = nil # we need a profile with an example of this and probably will need to use the API to accuratetly get this data
          start_date = Date.parse(item_text.scan(regex)[0].join(' '))
          
          includes_end_date = item_text.scan(regex).count > 1
          end_date = includes_end_date ? Date.parse(item_text.scan(regex)[0].join(' ')) : nil # we need a profile with an example of this and probably will need to use the API to accuratetly get this data

          certifications << { name:name, authority:authority, license:license, start_date:start_date, end_date:end_date }
        end
        return certifications
      end
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

    def get_country(page)
      return page.at(".locality").text.split(",").last.strip if page.search(".locality").first
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

    def get_first_name(page)
      return page.at(".given-name").text.strip if page.search(".given-name").first
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
    
    def get_industry(page)
      return page.at(".industry").text.gsub(/\s+/, " ").strip if page.search(".industry").first
    end

    def get_languages(page)
      languages = []
      # if the profile contains org data
      if page.search('ul.languages li.language').first
        
        # loop over each element with org data
        page.search('ul.languages li.language').each do |item|
          # find the h3 element within the above section and get the text with excess white space stripped
          language = item.at('h3').text
          proficiency = item.at('span.proficiency').text.gsub(/\s+|\n/, " ").strip
          languages << { language:language, proficiency:proficiency }
        end
        
        return languages
      end # page.search('ul.organizations li.organization').first
    end

    def get_last_name(page)
      return page.at(".family-name").text.strip if page.search(".family-name").first
    end

    def get_location(page)
      return page.at(".locality").text.split(",").first.strip if page.search(".locality").first
    end

    def get_organizations(page)
      organizations = []
      # if the profile contains org data
      if page.search('ul.organizations li.organization').first
        
        # loop over each element with org data
        page.search('ul.organizations li.organization').each do |item|
          # find the h3 element within the above section and get the text with excess white space stripped
          name = item.search('h3').text.gsub(/\s+|\n/, " ").strip
          position = nil # add this later
          occupation = nil # add this latetr too, this relates to the experience/work
          start_date = Date.parse(item.search('ul.specifics li').text.gsub(/\s+|\n/, " ").strip.split(' to ').first)
          if item.search('ul.specifics li').text.gsub(/\s+|\n/, " ").strip.split(' to ').last == 'Present'
            end_date = nil
          else
            Date.parse(item.search('ul.specifics li').text.gsub(/\s+|\n/, " ").strip.split(' to ').last)
          end
          
          organizations << { name: name, start_date: start_date, end_date: end_date }
        end
        
        return organizations
      end # page.search('ul.organizations li.organization').first
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

    def get_picture(page)
      return page.at("#profile-picture/img.photo").attributes['src'].value.strip if page.search("#profile-picture/img.photo").first
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
  
    def get_skills(page)
      page.search('.competency.show-bean').map{|skill|skill.text.strip if skill.text}
    end

    def get_summary(page)
      return page.at(".summary.description").text.gsub(/\s+|\n/, " ").strip if page.at(".summary.description")
    end

    def get_title(page)
      return page.at(".headline-title").text.gsub(/\s+/, " ").strip if page.search(".headline-title").first
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

  end
end
