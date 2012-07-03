module Linkedin
  class Client
    USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac FireFox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]
    attr_accessor :contacts ,:matched_tag,:probability

    def initialize(first_name,last_name ,company,options={})
      @first_name = first_name.downcase
      @last_name = last_name.downcase
      @company = company
      @country = options[:country] || "us"
      @search_linkedin_url = "http://#{@country}.linkedin.com/pub/dir/#{@first_name}/#{@last_name}"
      @contacts = []
      @links = []
      get_agent
    end

    def get_agent
      @agent = Mechanize.new
      @agent.user_agent_alias = USER_AGENTS.sample
      @agent.max_history = 0
      @agent
    end

    def get_contacts
      begin
        sleep(2+rand(4))
        puts "===>Father:Scrapping linkedin url "+ @search_linkedin_url
        @page=@agent.get @search_linkedin_url
        @page.search(".vcard").each do |node|
          @contacts << Linkedin::Contact.new(node)
        end
      rescue Mechanize::ResponseCodeError => e
        puts "RESCUE"
      end
      # why to return instance variables? (get_contacts is called only in client.rb)
      @contacts
    end

    #TODO need to refactor this function need seperate function of each case

    def get_verified_contact
      get_contacts
      @contacts.each do |contact|
        #check current company
        contact.current_companies.each do |company|
          if company[:current_company]
            if company[:current_company].match /#{@company}/i
              @matched_tag = "CURRENT"
              return contact
            end
          end
        end if contact.current_companies
        #title of profile
        if contact.title.match /#{@company}/i
          @matched_tag = "CURRENT"
          contact
        end
        #check past companies
        contact.past_companies.each do |company|
          if company[:past_company]
            if company[:past_company].match /#{@company}/i
              @matched_tag = "PAST"
              contact
            end
          end
        end if contact.past_companies
        #
        #Going in to profile homepage and then checking
        #
        sleep(2 + rand(4))
        puts "===>Child:Scrapping linkedin url: " + contact.linkedin_url
        profile = contact.get_profile(get_agent.get(contact.linkedin_url), contact.linkedin_url)
        #check current company
        profile.current_companies.each do |company|
          if company[:current_company]
            if company[:current_company].match /#{@company}/i
              @matched_tag = "CURRENT"
              profile
            end
          end
        end if profile.current_companies
        #title of profile
        if profile.title
          if profile.title.match /#{@company}/i
            @matched_tag = "CURRENT"
            profile
          end
        end
        #check past companies
        profile.past_companies.each do |company|
          if company[:past_company]
            if company[:past_company].match /#{@company}/i
              @matched_tag = "PAST"
              profile
            end
          end
        end if profile.past_companies
        #check recommended visitors
        if profile.recommended_visitors
          count = 0
          profile.recommended_visitors.each do |visitor|
            if visitor[:company]
              if visitor[:company].match /#{@company}/i
                count = count + 1
              end
            end
          end
          @probability = count / profile.recommended_visitors.length.to_f
          @matched_tag = "RECOMMENDED"
          profile if @probability >= 0.5
        end
      end unless @contacts.empty?
    end
  end
end
