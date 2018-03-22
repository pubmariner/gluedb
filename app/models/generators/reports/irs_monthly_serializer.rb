require 'spreadsheet'
require 'csv'
module Generators::Reports  
  class IrsMonthlySerializer

    CALENDER_YEAR = 2017

    def initialize
      @logger = Logger.new("#{Rails.root}/log/h36_exceptions.log")

      @carriers = Carrier.all.inject({}){|hash, carrier| hash[carrier.id] = carrier.name; hash}
      puts @carriers.inspect
      
      @policy_family_hash = {}
      load_npt_policies

      @h36_root_folder = "#{Rails.root}/irs/h36_#{Time.now.strftime('%m_%d_%Y_%H_%M')}"
      create_directory @h36_root_folder
    end

    def load_npt_policies
      @npt_policies = []
      CSV.foreach("#{Rails.root}/2017_NPT_PolicyIds.csv", headers: :true) do |row|
        @npt_policies << row[0].strip 
      end
      puts @npt_policies.count
    end

    def process    
      current = 0
      folder_count = 1

      # missing_irs_groups = []
      # multiple_taxhouseholds = []

      create_directory("#{@h36_root_folder}/transmission")
      create_new_irs_folder(folder_count)

      # non_auth_families = 0
      # non_auth_pols = 0
      # families_with_no_coverage = 0
      # missing_active_enrollments = 0

      # book = Spreadsheet.open "#{Rails.root}/EXCLUSION_2015_H41_EOY_201602111545.xls"
      # skip_list = book.worksheets.first.inject([]){|data, row| data << row[0].to_s.strip.to_i}.compact

      workbook = Spreadsheet::Workbook.new
      sheet = workbook.create_worksheet :name => '2017 H36 QHP'

      index = 0
      count = 0
      check = 0

      columns = ['IRS GROUP NUMBER', 'TAX HOUSEHOLDS', 'PRIMARY FIRST NAME', 'PRIMARY LAST NAME', 'PRIMARY SSN', 'PRIMARY DOB', 'SPOUSE FIRST NAME', 'SPOUSE LAST NAME', 'SPOUSE SSN', 'SPOUSE DOB']
      5.times {|i| columns += ["DEPENDENT#{i+1} FIRST NAME", "DEPENDENT#{i+1} LAST NAME", "DEPENDENT#{i+1} SSN", "DEPENDENT#{i+1} DOB"]}
      columns += ['POLICY ID', 'PLAN ID', 'ISSUER NAME', 'ISSUER EIN', 'POLICY START', 'POLICY END']
      5.times {|i| columns += ["PREMIUM#{i+1}", "SLCSP#{i+1}", "APTC#{i+1}"]}

      sheet.row(index).concat columns
      start = Time.now

      # Family.all.each do |family|
      # Family.where(:"e_case_id" => "2586018").each do |family|
      Family.where(:e_case_id.in => ["2240288","2456402","2516606","2586018","APYVEZRYFGXW","AZQSEJAPFFRM","DCHUHZUSYAEG","ECCCXVJSLEWT","FPSZLGIUWHAQ","GHKLIFPNLFYW","GKKKHNTIKNZL","IBRIGPEEVVNP","JWUGKFDSJSZO","KQJPQNHIOCIW","LDFMFFZIADLB","QQNUVGPJISGQ","SUNIJIWLWRMH","VJBMCTMKLUOP","YRESCUVSPPSD","ZYINJRORXJZC"]).each do |family|

      # Family.where(:"irs_groups.hbx_assigned_id" => 1000000000030349).to_a.each do |family|

      # [52428, 52918, 55598, 53303, 55584, 55577].inject([]){|families, policy_id|
      #   families << Family.where("family_members.person_id" => Moped::BSON::ObjectId.from_string(Policy.find(policy_id).subscriber.person.id)).first
      # }.each do |family|

        current += 1

        if current % 100 == 0
          puts "currently at #{current}"
        end

       # break if count > 50


        # begin

          if family.households.count > 1 || family.active_household.nil? 
            next
          end

          # if family.primary_applicant.nil?
          #   puts "------------found more than one household/activehousehold nil/primary aplicant nil---#{family.e_case_id}"
          # end

          # next unless family.active_household.has_aptc?(CALENDER_YEAR)
          
          active_enrollments = family.active_household.enrollments_for_year(CALENDER_YEAR)
          active_enrollments.reject!{|e| e.policy.subscriber.coverage_start >= Date.today.beginning_of_month }
          active_enrollments.reject!{|e| policies_to_skip.include?(e.policy.eg_id) }

          if active_enrollments.compact.empty?
            # puts "-----#{family.e_case_id}"
            # missing_active_enrollments += 1
            next
          end

          # active_pols = active_enrollments.map(&:policy)
          # if active_pols.detect{|x| skip_list.include?(x.id) }
          #   next
          # end

          if family.irs_groups.empty?
            # missing_irs_groups << family.e_case_id
            # puts "e_case_id --------- #{family.e_case_id}"
            next
          end

          # next unless family.active_household.tax_households.size == 0

          # non_authority_pols = active_enrollments.count { |enrollment| !enrollment.policy.belong_to_authority_member? }
          # if non_authority_pols > 0
          #   non_auth_pols += non_authority_pols
          #   non_auth_families += 1
          #   if non_authority_pols == active_enrollments.count
          #     families_with_no_coverage += 1
          #   end
          # end

          # build_policy_family_hash(active_pols, family)
          # active_pols = nil

          # count += 1

          # next if active_enrollments.map(&:policy).any? {|pol| multi_version_aptc?(pol) }
          # policy_ids = active_enrollments.map(&:policy_id)
          # next if (policy_ids & policies_to_skip).any?

          active_enrollments = nil

          if family.family_members.any? {|x| x.person.authority_member.ssn == '999999999' }
            # puts "ssn with all 9's --- #{family.e_case_id.inspect}"
            next
          end

          # if family.active_household.tax_households.count > 1
          #   # multiple_taxhouseholds << family.e_case_id
          #   # puts "---multiple tax households present"
          # elsif family.active_household.tax_households.count == 0
          #   # puts "-----no tax household----#{family.e_case_id}"
          # end

          # family.active_household.tax_households.each do |th|
          #   th.primary
          #   th.spouse
          #   th.dependents
          # end

          irs_group = build_irs_group(family)

          check += 1
          if check % 50 == 0
            puts "----found #{check} after check families so far"
          end

          if irs_group.insurance_policies.empty?
            puts "insurance policies empty --- #{family.e_case_id.inspect}"
            next
          end

          if irs_group.insurance_policies.any?{|policy| policy.no_coverage? || policy.no_premium_amount? }
            puts "family has wrong policy --- #{family.e_case_id.inspect}"
            next
          end

          # if irs_group.households[0].tax_households.empty?
          #   puts "EMPTY TAX HOUSEHOLDS #{family.e_case_id}"
          #   next
          # end

          # if irs_group.households[0].tax_households[0].primary.blank?
          #   puts "EMPTY TAX PRIMARY #{family.e_case_id}"
          #   next
          # end

          # puts irs_group.policies.inspect

          # ENABLE THIS FOR CSV EXPORT
          # rows = irs_group.to_csv
          # if rows.present?
          #   rows.each do |row|
          #     index += 1
          #     sheet.row(index).concat row

          #     if index % 50 == 0
          #       puts "----found #{index} index families so far"
          #     end
          #   end
          # end

          group_xml = IrsMonthlyXml.new(irs_group, family.e_case_id)
          group_xml.folder_path = "#{@h36_root_folder}/#{@h36_folder_name}"
          group_xml.serialize

          irs_group = nil
          group_xml = nil

          count += 1

          if count % 50 == 0
            puts "----found #{count} families so far"
          end

          if count % 3000 == 0
            merge_and_validate_xmls(folder_count)
            folder_count += 1
            create_new_irs_folder(folder_count)
          end

          if count % 100 == 0
            puts "so far --- #{count} --- out of #{current}"
            puts "time taken for current record ---- #{Time.now - start} seconds"
            start = Time.now
          end

        # rescue Exception => e
        #   puts "Failed #{family.e_case_id}--#{e.to_s}"
        # end
      end

      # print_families_with_samepolicy

      merge_and_validate_xmls(folder_count)
      create_manifest

      # workbook.write "#{Rails.root.to_s}/2016_H36_QHP_DATA_EXPORT#{Time.now.strftime("%m_%d_%Y_%H_%M")}.xls"

      puts count
      # puts multiple

      # puts missing_irs_groups.inspect
      # puts missing_irs_groups.count

      # puts multiple_taxhouseholds.count
      # puts multiple_taxhouseholds.inspect

      # puts non_auth_families
      # puts non_auth_pols
      # puts families_with_no_coverage
      # puts missing_active_enrollments
    end

    def build_irs_group(family)
      builder = Generators::Reports::IrsGroupBuilder.new(family)
      builder.carrier_hash = @carriers
      builder.npt_policies = @npt_policies
      builder.calender_year = CALENDER_YEAR
      builder.process
      builder.npt_policies = []
      builder.irs_group
    end

    def print_families_with_samepolicy
      @policy_family_hash.each do |policy_id, ecases|
        if ecases.count > 1
          puts "#{policy_id}---#{ecases.join(',').inspect}"
        end
      end   
    end

    def build_policy_family_hash(active_pols, family)
      active_pols.each do |pol|
        if @policy_family_hash.has_key?(pol.id)
          @policy_family_hash[pol.id] = @policy_family_hash[pol.id] + [family.e_case_id]
        else
          @policy_family_hash[pol.id] = [family.e_case_id]
        end
      end
    end

    def merge_and_validate_xmls(folder_count)
      folder_num = prepend_zeros(folder_count.to_s, 5)
      xml_merge = Generators::Reports::IrsXmlMerger.new("#{@h36_root_folder}/#{@h36_folder_name}", folder_num)
      xml_merge.irs_monthly_folder = @h36_root_folder
      xml_merge.process
      xml_merge.validate
    end

    def create_manifest
      Generators::Reports::IrsMonthlyManifest.new.create("#{@h36_root_folder}/transmission")
    end

    private

    def policies_to_skip
      ["738055", "738228", "881248", "730395", "738311", "746691", "881192", "793210", 
        "880447", "730336", "731561", "730060", "754704", "881876", "742221", "758011", 
        "730744", "982271", "746272", "747000", "758045", "745036", "746940", "741275", 
        "741958", "881237", "738996", "742155", "743624", "744471", "961965", "749935", 
        "758521", "745313", "746116", "881185", "747248", "757019", "749107", "881140", 
        "750442", "750445", "881394", "881694", "756358", "881871", "760095", "761825", 
        "881436", "908772", "763097", "743577", "756109", "756119", "774725", "774726", 
        "881167", "881691", "882107", "741304", "918286", "765857", "751686", "841444", 
        "841445", "842069", "747256", "750728", "881222", "881863", "744707", "747075", 
        "881229", "909907", "909922", "782045", "782046", "954932", "954938", "742407", 
        "881880", "947498"]
    end

    def create_new_irs_folder(folder_count)
      folder_number = prepend_zeros(folder_count.to_s, 3)
      @h36_folder_name = "DCHBX_H36_#{Time.now.strftime('%H_%M_%d_%m_%Y')}_#{folder_number}"
      create_directory "#{@h36_root_folder}/#{@h36_folder_name}"
    end

    def prepend_zeros(number, n)
      (n - number.to_s.size).times { number.prepend('0') }
      number
    end

    def create_directory(path)
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end
      Dir.mkdir path
    end
  end
end