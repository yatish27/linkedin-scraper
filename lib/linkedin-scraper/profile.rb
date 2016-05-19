# -*- encoding: utf-8 -*-
module Linkedin
  class Profile
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
      recommended_visitors )

    attr_reader :page, :linkedin_url

    def initialize(url, options = {})
      @linkedin_url = url
      @options = options
      @page = http_client.get(url)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def first_name
      @first_name ||= (@page.at('.fn').text.split(' ', 2)[0].strip if @page.at('.fn'))
    end

    def last_name
      @last_name ||= (@page.at('.fn').text.split(' ', 2)[1].strip if @page.at('.fn'))
    end

    def title
      @title ||= (@page.at('.title').text.gsub(/\s+/, ' ').strip if @page.at('.title'))
    end

    def location
      @location ||= (@page.at('.locality').text.split(',').first.strip if @page.at('.locality'))
    end

    def country
      @country ||= (@page.at('.locality').text.split(',').last.strip if @page.at('.locality'))
    end

    def number_of_connections
      if @page.at('.member-connections')
        @connections ||= (@page.at('.member-connections').text.match(/[0-9]+[\+]{0,1}/)[0])
      end
    end

    def industry
      if @page.at('#demographics .descriptor')
        @industry ||= (@page.search('#demographics .descriptor')[-1].text.gsub(/\s+/, ' ').strip)
      end
    end

    def summary
      @summary ||= (@page.at('#summary .description').text.gsub(/\s+/, ' ').strip if @page.at('#summary .description'))
    end

    def picture
      if @page.at('.profile-picture img')
        @picture ||= @page.at('.profile-picture img').attributes.values_at('src', 'data-delayed-url').
            compact.first.value.strip
      end
    end

    def skills
      @skills ||= (@page.search('.pills .skill:not(.see-less)').map { |skill| skill.text.strip if skill.text } rescue nil)
    end

    def past_companies
      @past_companies ||= get_companies.reject { |c| c[:end_date] == 'Present' }
    end

    def current_companies
      @current_companies ||= get_companies.find_all { |c| c[:end_date] == 'Present' }
    end

    def education
      @education ||= @page.search('.schools .school').map do |item|
        name = item.at('h4').text.gsub(/\s+|\n/, ' ').strip if item.at('h4')
        desc = item.search('h5').last.text.gsub(/\s+|\n/, ' ').strip if item.search('h5').last
        if item.search('h5').last.at('.degree')
          degree = item.search('h5').last.at('.degree').text.gsub(/\s+|\n/, ' ').strip.gsub(/,$/, '')
        end
        major = item.search('h5').last.at('.major').text.gsub(/\s+|\n/, ' ').strip if item.search('h5').last.at('.major')
        period = item.at('.date-range').text.gsub(/\s+|\n/, ' ').strip if item.at('.date-range')
        start_date, end_date = item.at('.date-range').text.gsub(/\s+|\n/, ' ').strip.split(' – ') rescue nil

        {
            name: name,
            description: desc,
            degree: degree,
            major: major,
            period: period,
            start_date: start_date,
            end_date: end_date
        }
      end
    end

    def websites
      @websites ||= @page.search('.websites li').flat_map do |site|
        url = site.at('a')['href']
        CGI.parse(URI.parse(url).query)['url']
      end
    end

    def groups
      @groups ||= @page.search('#groups .group .item-title').map do |item|
        name = item.text.gsub(/\s+|\n/, ' ').strip
        link = item.at('a')['href']

        { name: name, link: link }
      end
    end

    def organizations
      @organizations ||= @page.search('#background-organizations .section-item').map do |item|
        name = item.at('.summary').text.gsub(/\s+|\n/, ' ').strip rescue nil
        start_date, end_date = item.at('.organizations-date').text.gsub(/\s+|\n/, ' ').strip.split(' – ') rescue nil
        start_date = Date.parse(start_date) rescue nil
        end_date = Date.parse(end_date) rescue nil
        {name: name, start_date: start_date, end_date: end_date}
      end
    end

    def languages
      @languages ||= @page.search('.background-languages #languages ol li').map do |item|
        language = item.at('h4').text rescue nil
        proficiency = item.at('div.languages-proficiency').text.gsub(/\s+|\n/, ' ').strip rescue nil
        { language: language, proficiency: proficiency }
      end
    end

    def certifications
      @certifications ||= @page.search('background-certifications').map do |item|
        name = item.at('h4').text.gsub(/\s+|\n/, ' ').strip rescue nil
        authority = item.at('h5').text.gsub(/\s+|\n/, ' ').strip rescue nil
        license = item.at('.specifics/.licence-number').text.gsub(/\s+|\n/, ' ').strip rescue nil
        start_date = item.at('.certification-date').text.gsub(/\s+|\n/, ' ').strip rescue nil

        { name: name, authority: authority, license: license, start_date: start_date }
      end
    end


    def recommended_visitors
      @recommended_visitors ||= @page.search('.insights .browse-map/ul/li.profile-card').map do |node|
        visitor = {}
        visitor[:link] = node.at('a')['href']
        visitor[:name] = node.at('h4/a').text
        if node.at('.headline')
          visitor[:title], visitor[:company], _ = node.at('.headline').text.gsub('...', ' ').split(' at ')
        end
        visitor
      end
    end

    def projects
      @projects ||= @page.search('#projects .project').map do |node|
        project = {}
        start_date, end_date = node.at('.date-range').text.gsub(/\s+|\n/, ' ').strip.split(' – ') rescue nil

        project[:title] = node.at('.item-title').text
        project[:link] = CGI.parse(URI.parse(node.at('.item-title a')['href']).query)['url'][0] rescue nil
        project[:start_date] = parse_date(start_date) rescue nil
        project[:end_date] = parse_date(end_date) rescue nil
        project[:description] = node.at('.description').children().to_s rescue nil
        project[:associates] = node.search('.contributors .contributor').map { |c| c.at('a').text } rescue nil
        project
      end
    end

    def to_json
      require 'json'
      ATTRIBUTES.reduce({}) { |hash, attr| hash[attr.to_sym] = self.send(attr.to_sym); hash }.to_json
    end

    private
    def get_companies
      if @companies
        return @companies
      else
        @companies = []
      end

      @page.search('.positions .position').each do |node|
        company = {}
        company[:title] = node.at('.item-title').text.gsub(/\s+|\n/, ' ').strip if node.at('.item-title')
        company[:company] = node.at('.item-subtitle').text.gsub(/\s+|\n/, ' ').strip if node.at('.item-subtitle')
        company[:location] = node.at('.location').text if node.at('.location')
        company[:description] = node.at('.description').text.gsub(/\s+|\n/, ' ').strip if node.at('.description')
        company[:company_logo] = node.at('.logo a img').first[1] if node.at('.logo')

        start_date, end_date = node.at('.date-range').text.strip.split(' – ') rescue nil
        company[:duration] = node.at('.date-range').text[/.*\((.*)\)/, 1]
        company[:start_date] = parse_date(start_date) rescue nil

        if end_date && end_date.match(/Present/)
          company[:end_date] = 'Present'
        else
          company[:end_date] = parse_date(end_date) rescue nil
        end

        company_link = node.at('.item-subtitle').at('a')['href'] rescue nil
        if @options[:company_details] && company_link
          company.merge!(get_company_details(company_link))
        end

        @companies << company
      end

      @companies
    end

    def parse_date(date)
      date = '#{date}-01-01' if date =~ /^(19|20)\d{2}$/
      Date.parse(date)
    end

    def get_company_details(link)
      sleep(1.5)
      parsed = URI::parse(get_linkedin_company_url(link))
      parsed.fragment = parsed.query = nil
      result = { linkedin_company_url: parsed.to_s }

      page = http_client.get(parsed.to_s)
      company_details = JSON.parse(page.at('#stream-footer-embed-id-content').children.first.text) rescue nil
      if company_details
        result[:website] = company_details['website']
        result[:description] = company_details['description']
        result[:company_size] = company_details['size']
        result[:type] = company_details['companyType']
        result[:industry] = company_details['industry']
        result[:founded] = company_details['yearFounded']
        headquarters = company_details['headquarters']
        if headquarters
          result[:address] = %{#{headquarters['street1']} #{headquarters['street2']} #{headquarters['city']}, #{headquarters['state']} #{headquarters['zip']} #{headquarters['country']}}
          [:street1, :street2, :city, :zip, :state, :country].each do |section|
            result[section] = headquarters[section.to_s]
          end
        end
      end
      result
    end

    def http_client
      @http_client ||= Mechanize.new do |agent|
        agent.user_agent = RandomUserAgent.randomize
        if !@options.empty?
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
