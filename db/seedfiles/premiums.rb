Plan.collection.where.update({"$set" => {"premium_tables"=> []}}, {:multi => true})

require File.join(File.dirname(__FILE__), 'premiums_2014')
require File.join(File.dirname(__FILE__), 'dental_premiums_2014')
require File.join(File.dirname(__FILE__), 'premiums_2015')
require File.join(File.dirname(__FILE__), 'dental_premiums_2015')
