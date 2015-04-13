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
        self.exclusion_groups = config['exclusion_groups']

        random.seed(self.HIDDENSEED)

    def is_excluded(self, santas, exclusion_dict):
        """is_excluded(santas, exclusion_dict) -> True if any santa pair is specified by the
        exclusion dict, False otherwise"""
        for i in range(len(santas)):
            recipiant = santas[(i + 1) % len(santas)]
            santa = santas[i]
            if recipiant in exclusion_dict[santa]:
                return True
        return False

    def calculate_santa_order(self):
        """calculate_santa_order() -> returns a list of santas which satisfies all the exclusions specified"""
        santas = self.people.keys()

        #test exclusion groups
        exclusion_dict = dict()
        for santa in santas:
            ex = []
            for group in self.exclusion_groups:
                if group[0] == santa:
                    ex.append(group[1])
                elif group[1] == santa:
                    ex.append(group[0])
            exclusion_dict[santa] = ex
            print santa, "excludes\n", ex
        for group in self.exclusion_groups:
            if not ( group[0] in santas and group[1] in santas ):
                raise Exception("Exclusion groups contain people not in santas")

        i = 0
        while self.is_excluded(santas, exclusion_dict):
            i += 1
            random.shuffle(santas)

        print "Found assignment after only %d shuffles!" % i
        return santas

    def email_santas(self):
        """email_santas(santas = None) --> email secret santas where each santa is a santa to the next person in the list santas"""
        santas = self.calculate_santa_order()
        subject = "Your Secret Santa Assignment"
        sesconn = ses.connection.SESConnection(aws_access_key_id=self.AWS_ACCESS_KEY_ID,
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
