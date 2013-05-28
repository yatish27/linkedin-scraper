Linkedin Scraper
================

Linkedin-scraper is a gem for scraping linkedin public profiles.
You give it an URL, and it lets you easily get its title, name, country, area, current_companies and much more.

Installation
------------

Install the gem from RubyGems:

    gem install linkedin-scraper

This gem is tested on Ruby versions 1.8.7, 1.9.2 1.9.3 and 2.0.0

Usage
-----

Initialize a scraper instance for an URL, like this:

    profile = Linkedin::Profile.get_profile("http://www.linkedin.com/in/jeffweiner08")

Then you can see the scraped data like this:


    profile.first_name          #the First name of the contact

    profile.last_name           #the last name of the contact

    profile.name                #The Full name of the profile

    profile.title               #the linkedin job title

    profile.location            #the location of the contact

    profile.country             #the country of the contact

    profile.industry            #the domain for which the contact belongs

    profile.picture             #the profile pic url of contact

    profile.skills              #the skills of the profile

    profile.organizations       #the organizations of the profile

    profile.education           #Array of hashes for eduction

    profile.picture             #url of the profile picture


    profile.current_companies

    [
    [0] {
             :current_company => "LinkedIn",
               :current_title => "CEO",
         :current_company_url => "http://www.linkedin.com",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/linkedin?trk=ppro_cprof",
                         :url => "http://www.linkedin.com",
                        :type => "Public Company",
                :company_size => "1001-5000 employees",
                     :website => "http://www.linkedin.com",
                    :industry => "Internet",
                     :founded => "2003",
                     :address => "2029 Stierlin Court  Mountain View, CA 94043 United States"
    },
    [1] {
             :current_company => "Intuit",
               :current_title => "Member, Board of Directors",
         :current_company_url => "http://network.intuit.com/",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/intuit?trk=ppro_cprof",
                         :url => "http://network.intuit.com/",
                        :type => "Public Company",
                :company_size => "5001-10,000 employees",
                     :website => "http://network.intuit.com/",
                    :industry => "Computer Software",
                     :founded => "1983",
                     :address => "2632 Marine Way  Mountain View, CA 94043 United States"
    },
    [2] {
             :current_company => "DonorsChoose",
               :current_title => "Member, Board of Directors",
         :current_company_url => "http://www.donorschoose.org",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/donorschoose.org?trk=ppro_cprof",
                         :url => "http://www.donorschoose.org",
                        :type => "Nonprofit",
                :company_size => "51-200 employees",
                     :website => "http://www.donorschoose.org",
                    :industry => "Nonprofit Organization Management",
                     :founded => "2000",
                     :address => "213 West 35th Street 2nd Floor East New York, NY 10001 United States"
    },
    [3] {
            :current_company => "Malaria No More",
              :current_title => "Member, Board of Directors",
        :current_company_url => nil,
                :description => nil
    },
    [4] {
             :current_company => "Venture For America",
               :current_title => "Member, Advisory Board",
         :current_company_url => "http://ventureforamerica.org/",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/venture-for-america?trk=ppro_cprof",
                         :url => "http://ventureforamerica.org/",
                        :type => "Nonprofit",
                :company_size => "1-10 employees",
                     :website => "http://ventureforamerica.org/",
                    :industry => "Nonprofit Organization Management",
                     :founded => "2011"
    }
    ]


    profile.past_companies
    #Array of hash containing its past job companies and job profile
    #Example
    [
    [0] {
                :past_company => "Accel Partners",
                  :past_title => "Executive in Residence",
        :past_company_website => "http://www.facebook.com/accel",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/accel-partners?trk=ppro_cprof",
                         :url => "http://www.facebook.com/accel",
                        :type => "Partnership",
                :company_size => "51-200 employees",
                     :website => "http://www.facebook.com/accel",
                    :industry => "Venture Capital & Private Equity",
                     :address => "428 University Palo Alto, CA 94301 United States"
    },
    [1] {
                :past_company => "Greylock",
                  :past_title => "Executive in Residence",
        :past_company_website => "http://www.greylock.com",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/greylock-partners?trk=ppro_cprof",
                         :url => "http://www.greylock.com",
                        :type => "Partnership",
                :company_size => "51-200 employees",
                     :website => "http://www.greylock.com",
                    :industry => "Venture Capital & Private Equity",
                     :address => "2550 Sand Hill Road  Menlo Park, CA 94025 United States"
    },
    [2] {
                :past_company => "Yahoo!",
                  :past_title => "Executive Vice President Network Division",
        :past_company_website => "http://www.yahoo.com",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/yahoo?trk=ppro_cprof",
                         :url => "http://www.yahoo.com",
                        :type => "Public Company",
                :company_size => "10,001+ employees",
                     :website => "http://www.yahoo.com",
                    :industry => "Internet",
                     :founded => "1994",
                     :address => "701 First Avenue  Sunnyvale, CA 94089 United States"
    },
    [3] {
                :past_company => "Windsor Media",
                  :past_title => "Founding Partner",
        :past_company_website => nil,
                 :description => nil
    },
    [4] {
                :past_company => "Warner Bros.",
                  :past_title => "Vice President Online",
        :past_company_website => "http://www.warnerbros.com/",
                 :description => nil,
        :linkedin_company_url => "http://www.linkedin.com/company/warner-bros.-entertainment-group-of-companies?trk=ppro_cprof",
                         :url => "http://www.warnerbros.com/",
                        :type => "Public Company",
                :company_size => "10,001+ employees",
                     :website => "http://www.warnerbros.com/",
                    :industry => "Entertainment",
                     :address => "4000 Warner Boulevard  Burbank, CA 91522 United States"
    }
    ]


    profile.linkedin_url        #url of the profile

    profile.websites
    #Array of websites
    [
      [0]   "http://www.linkedin.com/"
    ]

    profile.groups
    #Array of hashes containing group name and link


    profile.education
    #Array of hashes for eduction

    profile.skills
    #Array of skills

    profile.picture
    #url of the profile picture


    profile.recommended_visitors
    #Its the list of visitors "Viewers of this profile also viewed..."
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



You're welcome to fork this project and send pull requests. I want to thank specially:
