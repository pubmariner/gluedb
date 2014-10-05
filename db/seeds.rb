# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Set up base types
require File.join(File.dirname(__FILE__),'seedfiles', 'carriers')
require File.join(File.dirname(__FILE__),'seedfiles', 'users')
require File.join(File.dirname(__FILE__),'seedfiles', 'plans')
require File.join(File.dirname(__FILE__),'seedfiles', 'premiums')
require File.join(File.dirname(__FILE__),'seedfiles', 'missing_dental_premiums')
require File.join(File.dirname(__FILE__),'seedfiles', 'premiums_2015')
require File.join(File.dirname(__FILE__),'seedfiles', 'brokers')
require File.join(File.dirname(__FILE__),'seedfiles', 'employers')
