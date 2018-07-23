
# This rake task updates the kind field for the given policy to "coverall".
# format RAILS_ENV=production bundle exec rake migrations:create_aptc_credits eg_id="abc123" start_on="1/1/2018" end_on="2/3/108" aptc=100.0 pre_amt_tot=2222 tot_res_amt=123
namespace :migrations do 
  desc "Generate Transforms"
  task :conversions => :environment do 
    require File.join(Rails.root,"app","data_migrations","conversions")
    carrier_id_map = {}
    Carrier.all.each do |c|
      carrier_id_map[c.id] = c
    end

    plan_id_map = {}
    active_year_hios_map = {}
    Plan.where(:year => {"$gte" => 2017}).each do |p|
      plan_id_map[p.id] = p
      active_year_hios_map[[p.year,p.hios_plan_id]] = p
    end

    Caches::CustomCache.allocate(Carrier, :cv2_carrier_cache, carrier_id_map)
    Caches::CustomCache.allocate(Plan, :cv2_plan_cache, plan_id_map)
    Caches::CustomCache.allocate(Plan, :cv2_hios_active_year_plan_cache, active_year_hios_map)
    gt = GenerateTransforms.new
    gt.generate_transforms
    Caches::CustomCache.release(Carrier, :cv2_carrier_cache)
    Caches::CustomCache.release(Plan, :cv2_plan_cache)
    Caches::CustomCache.release(Plan, :cv2_hios_active_year_plan_cache)
  end
end