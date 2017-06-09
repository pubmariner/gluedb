require 'rails_helper'

RSpec.shared_examples "a carrier" do |attributes|
  attributes.each do |attribute, value|
    it "should return #{value} from ##{attribute}" do
      expect(subject.send(attribute)).to eq(value)
    end
  end
end
RSpec.shared_examples "a carrier profile" do |attributes|
  attributes.each do |attribute, value|
    it "should return #{value} from ##{attribute}" do
      expect(subject.carrier_profiles.first.send(attribute)).to eq(value)
    end
  end
end
RSpec.describe 'Load Carrier Profiles', :type => :task do
	context "load carriers: update carrier profiles" do
    before :all do
      Rake.application.rake_require "tasks/carrier_import"
      Rake::Task.define_task(:environment)
    end

     before :context do
      invoke_task
    end

    context "it should load carrier profile correctly" do
      let(:subject) { Carrier.find_by(name: "Altus") }
      
      it_should_behave_like "a carrier", { abbrev: "ALT",
                                                  hbx_carrier_id: "20001", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: false, 
                                                  shp_dtl: true
                                                }

      it_should_behave_like "a carrier profile", {fein: "050513223",
      											   profile_name: "ALT_SHP"}
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Blue Cross Blue Shield MA") }
      it_should_behave_like "a carrier", { abbrev: "BCBS",
                                                  hbx_carrier_id: "20002", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: true
                                                }

      it_should_behave_like "a carrier profile", {fein: "041045815",
      											   profile_name: "BCBS_SHP"}                                          
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Boston Medical Center Health Plan") }
      it_should_behave_like "a carrier", { abbrev: "BMCHP",
                                                  hbx_carrier_id: "20003", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "043373331",
      											   profile_name: "BMCHP_SHP"}                                           
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Delta") }
      it_should_behave_like "a carrier", { abbrev: "DDA",
                                                  hbx_carrier_id: "20004", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: false, 
                                                  shp_dtl: true
                                                }
      it_should_behave_like "a carrier profile", {fein: "046143185", 
      											   profile_name: "DDA_SHP"}
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "FCHP") }
      it_should_behave_like "a carrier", { abbrev: "FCHP",
                                                  hbx_carrier_id: "20005", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "237442369",  
      											   profile_name: "FCHP_SHP"}
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Guardian") }
      it_should_behave_like "a carrier", { abbrev: "GUARD",
                                                  hbx_carrier_id: "20006", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: false, 
                                                  shp_dtl: true
                                                }
      it_should_behave_like "a carrier profile", {fein: "135123390",  
      											   profile_name: "GUARD_SHP" }
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Health New England") }
      it_should_behave_like "a carrier", { abbrev: "HNE",
                                                  hbx_carrier_id: "20007", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "042864973",
      											   profile_name: "HNE_SHP" }
    end

     context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Harvard Pilgrim Health Care") }
      it_should_behave_like "a carrier", { abbrev: "HPHC",
                                                  hbx_carrier_id: "20008", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "042452600",
      											   profile_name: "HPHC_SHP" }
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Minuteman Health") }
      it_should_behave_like "a carrier", { abbrev: "MHI",
                                                  hbx_carrier_id: "20009", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "453596033", 
      											   profile_name: "MHI_SHP" }
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Neighborhood Health Plan") }
      it_should_behave_like "a carrier", { abbrev: "NHP",
                                                  hbx_carrier_id: "200010", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "234547586", 
      											   profile_name: "NHP_SHP"  }
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Tufts Health Plan Direct") }
      it_should_behave_like "a carrier", { abbrev: "THPD",
                                                  hbx_carrier_id: "200011", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "800721489",
      											   profile_name: "THPD_SHP"  }
    end

    context "it should load carrier profile correctly" do
      subject { Carrier.find_by(name: "Tufts Health Plan Premier") }
      it_should_behave_like "a carrier", { abbrev: "THPP",
                                                  hbx_carrier_id: "200012", 
                                                  ind_hlt: false, 
                                                  ind_dtl: false, 
                                                  shp_hlt: true, 
                                                  shp_dtl: false
                                                }
      it_should_behave_like "a carrier profile", {fein: "042674079", 
      											   profile_name: "THPP_SHP"  }
    end

    private

    def invoke_task
      Rake::Task["carrier:import"].invoke
    end
  end
end
