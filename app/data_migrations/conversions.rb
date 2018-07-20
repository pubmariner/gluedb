require 'pry'
require File.join(Rails.root, "lib/mongoid_migration_task")
require_relative 'scripts/generate_c_v_2_1s.rb'

class Conversions < MongoidMigrationTask


  def migrate
    eg_ids = ENV['eg_ids'].split(',').map(&:to_i)
    reason_code = ENV['reason_code']
    cv21 = GenerateCV21s.new(eg_ids,reason_code).run


  end
end