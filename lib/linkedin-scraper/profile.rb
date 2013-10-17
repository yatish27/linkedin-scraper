# -*- coding: utf-8 -*-
module Linkedin
  class Profile

    USER_AGENTS = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Linux Konqueror']

    ATTRIBUTES = %w(name first_name last_name title location country industry summary picture linkedin_url education groups websites languages skills certifications organizations past_companies current_companies recommended_visitors)

    attr_reader :page, :linkedin_url

    def self.get_profile(url)
      begin
        Linkedin::Profile.new(url)
      rescue => e
        puts e
      end
    end

    def initialize(url)
      @linkedin_url = url
      @page         = http_client.get(url)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def first_name
      @first_name ||= (@page.at('.given-name').text.strip if @page.at('.given-name'))
    end

    def last_name
      @last_name ||= (@page.at('.family-name').text.strip if @page.at('.family-name'))
    end

    def title
      @title ||= (@page.at('.headline-title').text.gsub(/\s+/, ' ').strip if @page.at('.headline-title'))
    end

    def location
      @location ||= (@page.at('.locality').text.split(',').first.strip if @page.at('.locality'))
    end

    def country
      @country ||= (@page.at('.locality').text.split(',').last.strip if @page.at('.locality'))
    end

    def industry
      @industry ||= (@page.at('.industry').text.gsub(/\s+/, ' ').strip if @page.at('.industry'))
    end

    def summary
      @summary ||= (@page.at('.description.summary').text.gsub(/\s+/, ' ').strip if @page.at('.description.summary'))
    end

    def picture
      @picture ||= (@page.at('#profile-picture/img.photo').attributes['src'].value.strip if @page.at('#profile-picture/img.photo'))
    end

    def skills
      @skills ||= (@page.search('.competency.show-bean').map{|skill| skill.text.strip if skill.text} rescue nil)
    end

    def past_companies
      @past_companies ||= get_companies('past')
    end

    def current_companies
      @current_companies ||= get_companies('current')
    end

    def education
      unless @education
        @education = []
        if @page.search('.position.education.vevent.vcard').first
          @education = @page.search('.position.education.vevent.vcard').map do |item|
            name   = item.at('h3').text.gsub(/\s+|\n/, ' ').strip      if item.at('h3')
            desc   = item.at('h4').text.gsub(/\s+|\n/, ' ').strip      if item.at('h4')
            period = item.at('.period').text.gsub(/\s+|\n/, ' ').strip if item.at('.period')

            {:name => name, :description => desc, :period => period}
          end
        end
      end
      @education
    end

    def websites
      unless @websites
        @websites = []
        if @page.search('.website').first
          @websites = @page.search('.website').map do |site|
            url = site.at('a')['href']
            url = "http://www.linkedin.com#{url}"
            CGI.parse(URI.parse(url).query)['url']
          end.flatten!
        end
      end
      @websites
    end

    def groups
      unless @groups
        @groups = []
        if page.search('.group-data').first
          @groups = page.search('.group-data').each do |item|
            name = item.text.gsub(/\s+|\n/, ' ').strip
            link = "http://www.linkedin.com#{item.at('a')['href']}"
            {:name => name, :link => link}
          end
        end
      end
      @groups
    end

    def organizations
      unless @organizations
        @organizations = []
        if @page.search('ul.organizations/li.organization').first
          @organizations = @page.search('ul.organizations/li.organization').map do |item|

            name       = item.search('h3').text.gsub(/\s+|\n/, ' ').strip rescue nil
            start_date, end_date = item.search('ul.specifics li').text.gsub(/\s+|\n/, ' ').strip.split(' to ')
            start_date = Date.parse(start_date) rescue nil
            end_date   = Date.parse(end_date)   rescue nil
            {:name => name, :start_date => start_date, :end_date => end_date}
          end
        end
      end
      @organizations
    end

    def languages
      unless @languages
        @languages = []
        if @page.at('ul.languages/li.language')
          @languages = @page.search('ul.languages/li.language').map do |item|
            language    = item.at('h3').text rescue nil
            proficiency = item.at('span.proficiency').text.gsub(/\s+|\n/, ' ').strip rescue nil
            {:language=> language, :proficiency => proficiency }
          end
        end
      end
      @languages
    end

    def certifications
      unless @certtifications
        @certifications = []
        if @page.at('ul.certifications/li.certification')
          @certifications = @page.search('ul.certifications/li.certification').map do |item|
            name       = item.at('h3').text.gsub(/\s+|\n/, ' ').strip                         rescue nil
            authority  = item.at('.specifics/.org').text.gsub(/\s+|\n/, ' ').strip            rescue nil
            license    = item.at('.specifics/.licence-number').text.gsub(/\s+|\n/, ' ').strip rescue nil
            start_date = item.at('.specifics/.dtstart').text.gsub(/\s+|\n/, ' ').strip        rescue nil

            {:name => name, :authority => authority, :license => license, :start_date => start_date}
          end
        end
      end
      @certifications
    end


    def recommended_visitors
      unless @recommended_visitors
        @recommended_visitors = []
        if @page.at('.browsemap/.content/ul/li')
          @recommended_visitors = @page.search('.browsemap/.content/ul/li').map do |visitor|
            v = {}
            v[:link]    = visitor.at('a')['href']
            v[:name]    = visitor.at('strong/a').text
            v[:title]   = visitor.at('.headline').text.gsub('...',' ').split(' at ').first
            v[:company] = visitor.at('.headline').text.gsub('...',' ').split(' at ')[1]
            v
          end
        end
      end
      @recommended_visitors
    end

    def to_json
      require 'json'
      ATTRIBUTES.reduce({}){ |hash,attr| hash[attr.to_sym] = self.send(attr.to_sym);hash }.to_json
    end


    private

    def get_companies(type)
      companies = []
      if @page.search(".position.experience.vevent.vcard.summary-#{type}").first
        @page.search(".position.experience.vevent.vcard.summary-#{type}").each do |node|

          company               = {}
          company[:title]       = node.at('h3').text.gsub(/\s+|\n/, ' ').strip if node.at('h3')
          company[:company]     = node.at('h4').text.gsub(/\s+|\n/, ' ').strip if node.at('h4')
          company[:description] = node.at(".description.#{type}-position").text.gsub(/\s+|\n/, ' ').strip if node.at(".description.#{type}-position")
          start_date  = node.at('.dtstart').text.gsub(/\s+|\n/, ' ').strip rescue nil
          company[:start_date] = Date.parse(start_date) rescue nil

          end_date  = node.at('.dtend').text.gsub(/\s+|\n/, ' ').strip rescue nil
          company[:end_date] = Date.parse(end_date) rescue nil


          company_link = node.at('h4/strong/a')['href'] if node.at('h4/strong/a')

          result = get_company_details(company_link)
          companies << company.merge!(result)
        end
      end
      companies
    end


    def get_company_details(link)
      result = {:linkedin_company_url => "http://www.linkedin.com#{link}"}
      page = http_client.get(result[:linkedin_company_url])

      result[:url] = page.at('.basic-info/div/dl/dd/a').text if page.at('.basic-info/div/dl/dd/a')
      node_2 = page.at('.basic-info/.content.inner-mod')
      if node_2
        node_2.search('dd').zip(node_2.search('dt')).each do |value,title|
          result[title.text.gsub(' ','_').downcase.to_sym] = value.text.strip
        end
      end
      result[:address] = page.at('.vcard.hq').at('.adr').text.gsub("\n",' ').strip if page.at('.vcard.hq')
      result
    end

    def http_client
      Mechanize.new do |agent|
        agent.user_agent_alias = USER_AGENTS.sample
        agent.max_history = 0
      end
    end

  end
end
