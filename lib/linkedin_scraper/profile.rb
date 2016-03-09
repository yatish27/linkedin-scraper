# -*- encoding: utf-8 -*-
module Linkedin
  class Profile

    #USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac Firefox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]
    USER_AGENTS = [
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6",
      "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:5.0) Gecko/20100101 Firefox/5.0",
      "Mozilla/5.0 (Windows NT 6.1.1; rv:5.0) Gecko/20100101 Firefox/5.0",
      "Mozilla/5.0 (X11; U; Linux i586; de; rv:5.0) Gecko/20100101 Firefox/5.0",
      "Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.1 (KHTML, like Gecko) Ubuntu/11.04 Chromium/14.0.825.0 Chrome/14.0.825.0 Safari/535.1",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.824.0 Safari/535.1",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:5.0) Gecko/20100101 Firefox/5.0",
      "Mozilla/5.0 (Macintosh; PPC MacOS X; rv:5.0) Gecko/20110615 Firefox/5.0",
      "Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))",
      "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; Media Center PC 4.0; SLCC1; .NET CLR 3.0.04320)",
      "Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)",
      "Mozilla/5.0 (compatible; Konqueror/4.5; FreeBSD) KHTML/4.5.4 (like Gecko)",
      "Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00",
      "Opera/9.80 (X11; Linux x86_64; U; fr) Presto/2.9.168 Version/11.50",
      "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1",
      "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1"
    ]
    ATTRIBUTES = %w(
    name
    first_name
    last_name
    title
    location
    number_of_connections
    country
    industry
    summary
    picture
    projects
    linkedin_url
    education
    groups
    websites
    languages
    skills
    certifications
    organizations
    past_companies
    current_companies
    recommended_visitors)

    attr_reader :page, :linkedin_url

    # support old version
    def self.get_profile(url, options = {})
      Linkedin::Profile.new(url, options)
    rescue => e
      puts e
    end

    def initialize(url, options = {})
      @linkedin_url = url
      @options = options
      @page = http_client.get(url)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def first_name
      @first_name ||= (@page.at(".fn").text.split(" ", 2)[0].strip if @page.at(".fn"))
    end

    def last_name
      @last_name ||= (@page.at(".fn").text.split(" ", 2)[1].strip if @page.at(".fn"))
    end

    def title
      @title ||= (@page.at(".title").text.gsub(/\s+/, " ").strip if @page.at(".title"))
    end

    def location
      @location ||= (@page.at(".locality").text.split(",").first.strip if @page.at(".locality"))
    end

    def number_of_connections
      @connections ||= (@page.at(".member-connections").text.match(/[0-9]+[\+]{0,1}/)[0]) if @page.at(".member-connections")
    end

    def country
      @country ||= (@page.at(".locality").text.split(",").last.strip if @page.at(".locality"))
    end

    def industry
      @industry ||= (@page.search("#demographics .descriptor")[-1].text.gsub(/\s+/, " ").strip if @page.at("#demographics .descriptor"))
    end

    def summary
      @summary ||= (@page.at("#summary .description").text.gsub(/\s+/, " ").strip if @page.at("#summary .description"))
    end

    def picture
      @picture ||= (@page.at('.profile-picture img').attributes.values_at('src','data-delayed-url').compact.first.value.strip if @page.at('.profile-picture img'))
    end

    def skills
      @skills ||= (@page.search(".pills .skill").map { |skill| skill.text.strip if skill.text } rescue nil)
    end

    def past_companies
      @past_companies ||= get_companies().reject { |c| c[:end_date] == "Present"}
    end

    def current_companies
      @current_companies ||= get_companies().find_all{ |c| c[:end_date] == "Present"}
    end

    def education
      @education ||= @page.search(".schools .school").map do |item|
        name = item.at("h4").text.gsub(/\s+|\n/, " ").strip if item.at("h4")
        desc = item.search("h5").last.text.gsub(/\s+|\n/, " ").strip if item.search("h5").last
        degree = item.search("h5").last.at(".degree").text.gsub(/\s+|\n/, " ").strip.gsub(/,$/, "") if item.search("h5").last.at(".degree")
        major = item.search("h5").last.at(".major").text.gsub(/\s+|\n/, " ").strip      if item.search("h5").last.at(".major")
        period = item.at(".date-range").text.gsub(/\s+|\n/, " ").strip if item.at(".date-range")
        start_date, end_date = item.at(".date-range").text.gsub(/\s+|\n/, " ").strip.split(" – ") rescue nil
        {:name => name, :description => desc, :degree => degree, :major => major, :period => period, :start_date => start_date, :end_date => end_date }
      end
    end

    def websites
      @websites ||= @page.search(".websites li").flat_map do |site|
        url = site.at("a")["href"]
        CGI.parse(URI.parse(url).query)["url"]
      end
    end

    def groups
      @groups ||= @page.search("#groups .group .item-title").map do |item|
        name = item.text.gsub(/\s+|\n/, " ").strip
        link = item.at("a")['href']
        { :name => name, :link => link }
      end
    end

    def organizations
      @organizations ||= @page.search("#background-organizations .section-item").map do |item|
        name = item.at(".summary").text.gsub(/\s+|\n/, " ").strip rescue nil
        start_date, end_date = item.at(".organizations-date").text.gsub(/\s+|\n/, " ").strip.split(" – ") rescue nil
        start_date = Date.parse(start_date) rescue nil
        end_date = Date.parse(end_date)   rescue nil
        { :name => name, :start_date => start_date, :end_date => end_date }
      end
    end

    def languages
      @languages ||= @page.search(".background-languages #languages ol li").map do |item|
        language = item.at("h4").text rescue nil
        proficiency = item.at("div.languages-proficiency").text.gsub(/\s+|\n/, " ").strip rescue nil
        { :language => language, :proficiency => proficiency }
      end
    end

    def certifications
      @certifications ||= @page.search("background-certifications").map do |item|
        name       = item.at("h4").text.gsub(/\s+|\n/, " ").strip rescue nil
        authority  = item.at("h5").text.gsub(/\s+|\n/, " ").strip rescue nil
        license    = item.at(".specifics/.licence-number").text.gsub(/\s+|\n/, " ").strip rescue nil
        start_date = item.at(".certification-date").text.gsub(/\s+|\n/, " ").strip rescue nil

        { :name => name, :authority => authority, :license => license, :start_date => start_date }
      end
    end


    def recommended_visitors
      @recommended_visitors ||= @page.search(".insights .browse-map/ul/li.profile-card").map do |visitor|
        v = {}
        v[:link] = visitor.at("a")["href"]
        v[:name] = visitor.at("h4/a").text
        if visitor.at(".headline")
          v[:title] = visitor.at(".headline").text.gsub("...", " ").split(" at ").first
          v[:company] = visitor.at(".headline").text.gsub("...", " ").split(" at ")[1]
        end
        v
      end
    end

    def projects
      @projects ||= @page.search("#projects .project").map do |project|
        p = {}
        start_date, end_date = project.at("date-range").text.gsub(/\s+|\n/, " ").strip.split(" – ") rescue nil

        p[:title] = project.at(".item-title").text
        p[:link] =  CGI.parse(URI.parse(project.at(".item-title a")['href']).query)["url"][0] rescue nil
        p[:start_date] = parse_date(start_date) rescue nil
        p[:end_date] = parse_date(end_date)  rescue nil
        p[:description] = project.at(".description").text rescue nil
        p[:associates] = project.search(".contributors .contributor").map{ |c| c.at("a").text } rescue nil
        p
      end
    end

    def to_json
      require "json"
      ATTRIBUTES.reduce({}){ |hash,attr| hash[attr.to_sym] = self.send(attr.to_sym);hash }.to_json
    end

    private
    #TODO Bad code Hot fix
    def get_companies()
      if @companies
        return @companies
      else
        @companies = []
      end

      @page.search(".positions .position").each do |node|
        company = {}
        company[:title] = node.at(".item-title").text.gsub(/\s+|\n/, " ").strip if node.at(".item-title")
        company[:company] = node.at(".item-subtitle").text.gsub(/\s+|\n/, " ").strip if node.at(".item-subtitle")
        company[:description] = node.at(".description").text.gsub(/\s+|\n/, " ").strip if node.at(".description")

        start_date, end_date = node.at(".meta").text.strip.split(" – ") rescue nil
        company[:duration] = node.at(".meta").text[/.*\((.*)\)/, 1]
        company[:start_date] = parse_date(start_date) rescue nil

        if end_date && end_date.match(/Present/)
          company[:end_date] = "Present"
        else
          company[:end_date] = parse_date(end_date) rescue nil
        end

        company_link = node.at(".item-subtitle").at("a")["href"] rescue nil
        if company_link
          result = get_company_details(company_link)
          @companies << company.merge!(result)
        else
          @companies << company
        end
      end

      @companies
    end

    def parse_date(date)
      date = "#{date}-01-01" if date =~ /^(19|20)\d{2}$/
      Date.parse(date)
    end

    def get_company_details(link)
      result = { :linkedin_company_url => get_linkedin_company_url(link) }
      page = http_client.get(result[:linkedin_company_url])

      result[:url] = page.at(".basic-info-about/ul/li/p/a").text if page.at(".basic-info-about/ul/li/p/a")
      node_2 = page.at(".basic-info-about/ul")
      if node_2
        node_2.search("p").zip(node_2.search("h4")).each do |value, title|
          result[title.text.gsub(" ", "_").downcase.to_sym] = value.text.strip
        end
      end
      result[:address] = page.at(".vcard.hq").at(".adr").text.gsub("\n", " ").strip if page.at(".vcard.hq")
      result
    end

    def http_client
      Mechanize.new do |agent|
        agent.user_agent = USER_AGENTS.sample
        unless @options.empty?
          agent.set_proxy(@options[:proxy_ip], @options[:proxy_port], @options[:username], @options[:password])
        end
        agent.max_history = 0
      end
    end

    def get_linkedin_company_url(link)
      http = %r{http://www.linkedin.com/}
      https = %r{https://www.linkedin.com/}
      if http.match(link) || https.match(link)
        link
      else
        "http://www.linkedin.com/#{link}"
      end
    end
  end
end
