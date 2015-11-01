# SecretSanta

## Overview

This is a simple tool designed to reduce the stress and hassle of picking secret santas for a group of people, while
also remaining fair, impartial, and, most importantly, secret.  At present, the operator will provide a list of
people with their contact info, along with a list of pairs of people who should not be set up as secret santas with each
 other, such as spouses, siblings, or rivals.

## Operation

To run, the following prerequisite Python packages need to be installed:

 - simplejson
 - boto

Then simply create a config.json to include the contact information,
exclusion couples (pairs of people who shouldn't get gifts for each other),
exclusion list (potential senders who shouldn't send gifts to a recipient for some reason),
and AWS credential information.
A sample config.json looks like this:

    {"Name":"SampleConfig",
    "randomseed":0,
    "aws_key_id":"",
    "aws_secret":"",
    "from_email":"email@domain.com",
    "people":{"name":"email"},
    "exclusion_couples":[["brother","sister"]],
    "exclusion_list":[["sender","excluded recipient"]]}

Do not share this config.json, this should go without saying, but...

