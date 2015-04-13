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

Then simply create a config.json to include the contact information, exclusion pairs, and AWS credential information.
A sample config.json looks like this:

    {"Name":"SampleConfig",
    "randomseed":0,
    "aws_key_id":"",
    "aws_secret":"",
    "from_email":"email@domain.com",
    "people":{"name":"email"},
    "exclusion_groups":[["name","name"]]}

Do not share this config.json, this should go without saying, but

