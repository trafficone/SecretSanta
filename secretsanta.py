from boto import ses
import random
import simplejson as json


class Santadriver(object):
    """HO HO HO! Santa Driver takes the people who are in your config.json and
    emails them who they are a secret santa to! You can tell it who can't be a secret santa
    be they, siblings, SO's, or naughty ones who don't get along."""

    def __init__(self, config, debug=None):
        """Santadriver(config, debug=None) -> initializes Santa selection via info in config.json"""
        self.debug = False if debug is None or type(debug) != type(True) else debug
        self.HIDDENSEED = 0 if 'randomseed' not in config else config['randomseed']
        self.AWS_ACCESS_KEY_ID = config['aws_key_id']
        self.AWS_SECRET_ACCESS_KEY = config['aws_secret']
        self.FROM = config['from_email']
        #a dict containing name/email pairs
        self.people = config['people']
        #a list containing pairs of people who should not be secret santas to each other
        exclusion_couples = config['exclusion_couples']
        #a list of pairs people who should not be secret santas to the second person (i.e. last year's santas)
        exclusion_list = config['exclusion_list']
        self.exclusion_dict = self.generate_exclusion_dict(exclusion_couples,exclusion_list)
        random.seed(self.HIDDENSEED)

    def validate_exclusion_lists(self,exclusion_lists):
        """
        Validate that all the people in the exclusion lists are in the people being referenced.
        """
        missing_people = []
        for pair  in exclusion_lists:
            for person in pair:
                if person not in self.people:
                    missing_people.append(person)
        if len(missing_people) > 0:
            print "The following people are referenced, but not found: \n\t%s"%'\n\t'.join(missing_people)
            raise Exception("PeopleNotFound")

    def generate_exclusion_dict(self,exclusion_couples,exclusion_list):
        """generate_exclusion_dict(exclusion_couples,exclusion_list) -> exclusion_dict
           reorganizes the exclusion data into a dictionary of santas and people they are excluded from gifting to
        """
        self.validate_exclusion_lists(exclusion_couples + exclusion_list)

        santas = self.people.keys()
        exclusion_dict = dict()
        for santa in santas:
            exclusions_for_santa= []
            for pair in exclusion_couples:
                if pair[0] == santa:
                    exclusions_for_santa.append(pair[1])
                elif pair[1] == santa:
                    exclusions_for_santa.append(pair[0])
            for pair in exclusion_list:
                if pair[0] == santa:
                    exclusions_for_santa.append(pair[1])
            exclusion_dict[santa] = exclusions_for_santa
            print santa, "excludes\n", exclusions_for_santa
        return exclusion_dict

    def is_excluded(self, santas, exclusion_dict):
        """is_excluded(santas, exclusion_dict) -> True if any santa pair is specified by the
        exclusion dict, False otherwise"""
        for i in range(len(santas)):
            recipient = santas[(i + 1) % len(santas)]
            santa = santas[i]
            if recipient in exclusion_dict[santa]:
                return True
        return False

    def calculate_santa_order(self):
        """calculate_santa_order() -> returns a list of santas which satisfies all the exclusions specified"""
        santas = self.people.keys()

        i = 0
        while self.is_excluded(santas, self.exclusion_dict):
            i += 1
            if i % len(santas)**4 == 0 and i > 0:
                print i
                print "It is taking a long time to find a gift giving pattern that works. Check to verify that no member has been fully excluded by exclusion rules."
            random.shuffle(santas)

        print "Found assignment after only %d shuffles!" % i
        return santas

    def email_santas(self):
        """email_santas(santas = None) --> email secret santas where each santa is a santa to the next person in the list santas"""
        santas = self.calculate_santa_order()
        subject = "Your Secret Santa Assignment"
        sesconn = ses.connect_to_region('us-west-2',aws_access_key_id=self.AWS_ACCESS_KEY_ID,
                                               aws_secret_access_key=self.AWS_SECRET_ACCESS_KEY)

        print self.FROM
        for t in santas:
            assignment = (santas.index(t) + 1) % len(santas)
            message = ("Dear %s,\n"
                       "You have been assigned to be a secret santa to %s (email: %s).\n"
                       "Please check their address and wishlist. Check it twice.\n"
                       "You will not be told again who you are getting a gift for.\n"
                       "\n"
                       "Christmas is December 25, make me proud.\n"
                       "\n"
                       "Ho ho ho, DBNR\n"
                       "Santa Claus\n"
                      ) % (
                          t, santas[assignment], self.people[santas[assignment]])
            sesconn.send_email(self.FROM, subject, message, self.people[t])


if __name__ == '__main__':
    config = json.load(open('config.json', 'r'))
    s = Santadriver(config)
    s.email_santas()
