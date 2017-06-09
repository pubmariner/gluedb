# This rake task imports all the carriers into glue.
# bundle exec rake carrier:import

namespace :carrier do
  task :import => :environment do

    carrier = Carrier.new(name: "Altus", abbrev: "ALT", hbx_carrier_id: 20001, ind_hlt: false, ind_dtl: false, shp_hlt: false, shp_dtl: true)
    carrier.carrier_profiles.build(fein: "050513223", profile_name: "ALT_SHP")
    carrier.save

    carrier = Carrier.new(name: "Blue Cross Blue Shield MA", abbrev: "BCBS", hbx_carrier_id: 20002, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: true)
    carrier.carrier_profiles.build(fein: "041045815", profile_name: "BCBS_SHP")
    carrier.save

    carrier = Carrier.new(name: "Boston Medical Center Health Plan", abbrev: "BMCHP", hbx_carrier_id: 20003, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "043373331", profile_name: "BMCHP_SHP")
    carrier.save

    carrier = Carrier.new(name: "Delta", abbrev: "DDA", hbx_carrier_id: 20004, ind_hlt: false, ind_dtl: false, shp_hlt: false, shp_dtl: true)
    carrier.carrier_profiles.build(fein: "046143185", profile_name: "DDA_SHP")
    carrier.save

    carrier = Carrier.new(name: "FCHP", abbrev: "FCHP", hbx_carrier_id: 20005, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "237442369", profile_name: "FCHP_SHP")
    carrier.save

    carrier = Carrier.new(name: "Guardian", abbrev: "GUARD", hbx_carrier_id: 20006, ind_hlt: false, ind_dtl: false, shp_hlt: false, shp_dtl: true)
    carrier.carrier_profiles.build(fein: "135123390", profile_name: "GUARD_SHP")
    carrier.save

    carrier = Carrier.new(name: "Health New England", abbrev: "HNE", hbx_carrier_id: 20007, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "042864973", profile_name: "HNE_SHP")
    carrier.save

    carrier = Carrier.new(name: "Harvard Pilgrim Health Care", abbrev: "HPHC", hbx_carrier_id: 20008, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "042452600", profile_name: "HPHC_SHP")
    carrier.save

    carrier = Carrier.new(name: "Minuteman Health", abbrev: "MHI", hbx_carrier_id: 20009, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "453596033", profile_name: "MHI_SHP")
    carrier.save

    carrier = Carrier.new(name: "Neighborhood Health Plan", abbrev: "NHP", hbx_carrier_id: 200010, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "234547586", profile_name: "NHP_SHP")
    carrier.save

    carrier = Carrier.new(name: "Tufts Health Plan Direct", abbrev: "THPD", hbx_carrier_id: 200011, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "800721489", profile_name: "THPD_SHP")
    carrier.save

    carrier = Carrier.new(name: "Tufts Health Plan Premier", abbrev: "THPP", hbx_carrier_id: 200012, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: false)
    carrier.carrier_profiles.build(fein: "042674079", profile_name: "THPP_SHP")
    carrier.save

    carrier = Carrier.new(name: "Commonwealth Health Insurance Connector Authority", abbrev: "CCA", hbx_carrier_id: 200013, ind_hlt: false, ind_dtl: false, shp_hlt: true, shp_dtl: true)
    carrier.carrier_profiles.build(fein: "562592010", profile_name: "CCA_SHP")
    carrier.save
  end
end