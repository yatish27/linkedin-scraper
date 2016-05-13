[![Build Status](https://secure.travis-ci.org/yatish27/linkedin-scraper.png)](http://travis-ci.org/yatish27/linkedin-scraper)
[![Gem Version](https://badge.fury.io/rb/linkedin-scraper.png)](http://badge.fury.io/rb/linkedin-scraper)

Linkedin Scraper
================

**2.0.0 is the new version. It does not support the `get_profile` method. It does not support Ruby 1.8**

Linkedin-scraper is a gem for scraping linkedin public profiles.
Given the URL of the profile, it gets the name, country, title, area, current companies, past companies,
organizations, skills, groups, etc


## Installation

Install the gem from RubyGems:

    gem install linkedin-scraper

This gem is tested on 1.9.2, 1.9.3, 2.0.0, 2.2, 2.3

## Usage
Include the gem

    require 'linkedin-scraper'

Initialize a scraper instance

    profile = Linkedin::Profile.new("http://www.linkedin.com/in/jeffweiner08")


With a http web-proxy:

    profile = Linkedin::Profile.new("http://www.linkedin.com/in/jeffweiner08", { proxy_ip: '127.0.0.1', proxy_port: '3128', username: 'user', password: 'pass' })

The scraper can also get the details of each past and current companies. This will lead to multiple hits.
To enable this functionality, pass `company_details=true` in options. You can pass them along with proxy options
as well

    profile = Linkedin::Profile.new("http://www.linkedin.com/in/jeffweiner08", { company_details: true })

    profile = Linkedin::Profile.new("http://www.linkedin.com/in/jeffweiner08", { company_details: true, proxy_ip: '127.0.0.1', proxy_port: '3128', username: 'user', password: 'pass' })

The returning object responds to the following methods


    profile.first_name          # The first name of the contact

    profile.last_name           # The last name of the contact

    profile.name                # The full name of the profile

    profile.title               # The job title

	profile.summary             # The summary of the profile

    profile.location            # The location of the contact

    profile.country             # The country of the contact

    profile.industry            # The domain for which the contact belongs

    profile.picture             # The profile picture link of profile

    profile.skills              # Array of skills of the profile

    profile.organizations       # Array organizations of the profile

    profile.education           # Array of hashes for education

    profile.websites            # Array of websites

	profile.groups              # Array of groups

	profile.languages           # Array of languages

	profile.certifications      # Array of certifications

	profile.number_of_connections # The number of connections as a string


For current and past companies it also provides the details of the companies like company size, industry, address, etc
The company details will only be scraped if you pass company_details=true. It is false by default.


    profile.current_companies

    [
        [0] {
                           :title => "CEO",
                         :company => "LinkedIn",
                    :company_logo => "https://media.licdn.com/media/AAEAAQAAAAAAAAL0AAAAJGMwYWZhNTYxLWJkMTktNDAzMi05NzEzLTlhNzUxMGU0NDg0Mw.png",
                        :duration => "7 years 6 months",
                      :start_date => #<Date: 2008-12-01 ((2454802j,0s,0n),+0s,2299161j)>,
                        :end_date => "Present",
            :linkedin_company_url => "https://www.linkedin.com/company/linkedin",
                         :website => "http://www.linkedin.com",
                     :description => "The future is all about what you do next and we’re excited to help you get there. Ready for your moonshot? You're closer than you think. \r\n\r\nFounded in 2003, LinkedIn connects the world's professionals to make them more productive and successful. With more than 430 million members worldwide, including executives from every Fortune 500 company, LinkedIn is the world's largest professional network on the Internet. The company has a diversified business model with revenue coming from Talent Solutions, Marketing Solutions and Premium Subscriptions products. Headquartered in Silicon Valley, LinkedIn has offices across the globe.",
                    :company_size => "5001-10,000 employees",
                            :type => "Public Company",
                        :industry => "Internet",
                         :founded => 2003,
                         :address => "2029 Stierlin Court  Mountain View, CA 94043 United States",
                         :street1 => "2029 Stierlin Court",
                         :street2 => "",
                            :city => "Mountain View",
                             :zip => "94043",
                           :state => "CA",
                         :country => "United States"
        }
    ]
    [1] {
             :current_company => "Intuit",
               :current_title => "Member, Board of Directors",
         :current_company_url => "http://network.intuit.com/",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/intuit?trk=ppro_cprof",
                         :url => "http://network.intuit.com/",
                        :type => "Public Company",
                        .
                        .
                        .

    profile.past_companies
    # Same as current companies


    profile.recommended_visitors
    # It is the list of visitors "Viewers of this profile also viewed..."
    [
    [0] {
           :link => "http://www.linkedin.com/in/barackobama?trk=pub-pbmap",
           :name => "Barack Obama",
          :title => "President of the United States of ",
        :company => nil
    },
    [1] {
           :link => "http://www.linkedin.com/in/marissamayer?trk=pub-pbmap",
           :name => "Marissa Mayer",
          :title => "Yahoo!, President & CEO",
        :company => nil
    },
    [2] {
           :link => "http://www.linkedin.com/pub/sean-parker/0/1/826?trk=pub-pbmap",
           :name => "Sean Parker",
          :title => nil,
        :company => nil
    },
    [3] {
           :link => "http://www.linkedin.com/pub/eduardo-saverin/0/70a/31b?trk=pub-pbmap",
           :name => "Eduardo Saverin",
          :title => nil,
        :company => nil
    },
    [4] {
           :link => "http://www.linkedin.com/in/rbranson?trk=pub-pbmap",
           :name => "Richard Branson",
          :title => "Founder",
        :company => "Virgin Group"
    },
    [5] {
           :link => "http://www.linkedin.com/in/reidhoffman?trk=pub-pbmap",
           :name => "Reid Hoffman",
          :title => "Entrepreneur. Product Strategist.  ",
        :company => nil
    },
    [6] {
           :link => "http://www.linkedin.com/in/mdell?trk=pub-pbmap",
           :name => "Michael Dell",
          :title => "Chairman and CEO",
        :company => "Dell"
    },
    [7] {
           :link => "http://www.linkedin.com/in/mittromney?trk=pub-pbmap",
           :name => "Mitt Romney",
          :title => "Believe in America",
        :company => nil
    },
    [8] {
           :link => "http://www.linkedin.com/pub/sheryl-sandberg/2/665/512?trk=pub-pbmap",
           :name => "Sheryl Sandberg",
          :title => nil,
        :company => nil
    }
    ]


The gem also comes with a binary and can be used from the command line to get a json response of the scraped data.
It takes the url as the first argument. If the last argument is true it will fetch the company details for each company

    linkedin-scraper http://www.linkedin.com/in/jeffweiner08 127.0.0.1 3128 username password

    linkedin-scraper http://www.linkedin.com/in/jeffweiner08 127.0.0.1 3128 username password true


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yatish27/linkedin-scraper.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
