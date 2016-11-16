require 'aws-sdk'
require 'json'

class Santadriver
#HO HO HO! Santa Driver takes the people who are in your config.json and
#    emails them who they are a secret santa to! You can tell it who can't #be a secret santa
#    be they, siblings, SO's, or naughty ones who don't get along.
    def initialize(config,debug)
    #TODO: test for key in config before setting values
        @debug = debug
        @HIDDENSEED = config.keys().include?('randomseed') ? config['randomseed'] : 0
        @AWS_ACCESS_KEY_ID = config['aws_key_id']
        @AWS_SECRET_ACCESS_KEY = config['aws_secret']
        Aws.config[:credentials] = Aws::Credentials.new(@AWS_ACCESS_KEY_ID,@AWS_SECRET_ACCESS_KEY)
        
        @FROM = config[:from_email]
        @people = config[:people]
        
        exclusion_couples = config[:exclusion_couples]
        exclusion_list = config[:exclusion_list]
        #FIXME: ruby access method within class
        @exclusion_dict = generate_exclusion_dict(exclusion_couples,exclusion_list)
        #TODO: random.seed(@HIDDENSEED)
    end
    
    def validate_exclusion_lists(exclusion_lists)
        #Validate that all the people in the exclusion lists are in the people being referenced.
        missing_people = []
        for pair in exclusion_lists 
            for person in pair 
                if pair.include?(person) 
                    missing_people.push(person)
                end
            end
        end
        if missing_people.length() > 0 
            miss_out = missing_people.join("\n\t")
            puts "The following people are referenced, but now found: \n\t #{miss_out}"
            raise 'PeopleNotFound'
        end
    end
        
    def generate_exclusion_dict(exclusion_couples,exclusion_list) 
        validate_exclusion_lists (exclusion_couples + exlusion_list)
        
        santas = @people.keys()
        exclusion_dict = {}
        for santa in santas
            exclusions_for_santa = []
            for pair in exclusion_couples 
                if pair[0] == santa 
                    exclusions_for_santa.push(pair[1])
                elsif pair[1] == santa 
                    exclusions_for_santa.push(pair[0])
                end
            end
            for pair in exclusion_list 
                if pair[0] == santa 
                    exclusions_for_santa.append(pair[1])
                end
            end
            exclusion_dict[santa] = exclusions_for_santa
            puts "#{santa} excludes\n #{exclusions_for_santa}"
        end
        return exclusion_dict
    end
    
    
    def is_excluded(santas, exclusion_dict)
        for i in (0..santas.length() -1).to_a
            recipient = santas[(i+1) % santas.length()]
            santa = santas[i]
            if exclusion_dict[santa].include?(recipient)
                return true
            end
        end
        return false
    end
    
    def calculate_santa_order
        santas = @people.keys()
        i = 0
        while is_excluded(santas, @exclusion_dict)
            i += 1
            if i % ( santas.length ** 4 ) == 0 and i > 0
              puts i
              puts "It is taking a long time to find a gift-giving pattern that works.
                check to verify that no member has been fully excluded by exclusion rules."
            end
            santas.shuffle!()
        end
        
        puts "Found assignment after #{i} shuffles!"
        return santas
    end
    
    def email_santas
        santas = calculate_santa_order()
        subject = "Your Secret Santa Assignment"
        ses = Aws::SES::Client.new(region: 'us-west-2')
            #:region => 'us-west-2',
            #:access_key_id => @AWS_ACCESS_KEY_ID,
            #:secret_access_key => @AWS_SECRET_ACCESS_KEY)
        puts @FROM
        for t in santas
            assignment = (santas.index(t) + 1) % santas.length()
            message = "Dear #{t},\n"
                      " You have been assigned to be a secret santa to #{santas[assignment]} (email: #{@people[santas[assignment]]}).\n"
                      " Please check their address and wishlist. Check it twice.\n"
                      "\n"
                      "Chrismas is December 25, make me proud.\n"
                      "\n"
                      "Ho! Ho! Ho!\n"
                      "Santa \"Father Christmas\" Claus\n"
            ses.send_email({destination: {to_addresses: [ @people[t] ]},
                message: {body: {text: { data: message }}, 
                          subject: { data: subject}}, 
                          source: @FROM})
        end
    end
end

if __FILE__ == $0
    config = JSON.load(File.read('config.json'))
    s = Santadriver.new(config,false)
    s.email_santas()
end