require #AWS FIXME
#random?
#json for ruby

class Santadriver{
#HO HO HO! Santa Driver takes the people who are in your config.json and
#    emails them who they are a secret santa to! You can tell it who can't #be a secret santa
#    be they, siblings, SO's, or naughty ones who don't get along.
    def initialize(config)
    #TODO: test for key in config before setting values
        @debug = false #FIXME: ruby ternary
        @HIDDENSEED = 0 #same
        @AWS_ACCESS_KEY_ID = config[:aws_key_id]
        @AWS_SECRET_ACCESS_KEY = config[:aws_secret]
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
        for pair in exclusion_lists {
            for person in pair {
                if pair.include?(person) {
                    missing_people.push(person)
                }
            }
        }
        if missing_people.length() > 0 {
            miss_out = missing_people.join("\n\t")
            puts "The following people are referenced, but now found: \n\t #{miss_out}"
            raise 'PeopleNotFound'
        }
    end
        
    def generate_exclusion_dict(exclusion_couples,exclusion_list) 
    #
    #
    #
        validate_exclusion_lists (exclusion_couples + exlusion_list)
        
        santas = @people.keys()
        exclusion_dict = {}
        for santa in santas{
            exclusions_for_santa = []
            for pair in exclusion_couples {
                if pair[0] == santa {
                    exclusions_for_santa.push(pair[1])
                }
                elsif pair[1] == santa {
                    exclusions_for_santa.push(pair[0])
                }
            }
            for pair in exclusion_list {
                if pair[0] == santa {
                    exclusions_for_santa.append(pair[1])
                }
            }
            exclusion_dict[santa] = exclusions_for_santa
            puts "#{santa} excludes\n #{exclusions_for_santa}"
        }
        return exclusion_dict
    }
    
    def is_excluded(santas, exclusion_dict){
        
    }