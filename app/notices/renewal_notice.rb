class RenewalNotice < Notice

  def initialize(consumer, args = {})
    super
    @consumer = consumer
    @to = "raghuramg83@gmail.com"
    @subject = "Employee Renewal notice"
    @template = "notices/renewal_1b.html.erb"
    build
  end

  def build
    #family = @consumer.primary_family
    @family = Family.find_all_by_primary_applicant(@consumer).first
    @hbx_enrollments = @family.try(:latest_household).enrollments_for_year(2015) #.active || []
    @notice = PdfTemplates::EligibilityNotice.new
    @notice.primary_fullname = @consumer.full_name.titleize
    @notice.primary_identifier = @consumer.authority_member.hbx_member_id
    append_address(@consumer.addresses[0])
    append_enrollments(@hbx_enrollments)
  end

  def generate_notice
    generate_envelope
    save_pdf
    append_voter_application
  end

  def append_voter_application
    legal_rights = Rails.root.join('lib/pdf_pages', 'voter_application.pdf')
    join_pdfs([Rails.root.join('pdfs', @envelope), Rails.root.join('pdfs', @file_name), legal_rights])
  end

  def append_address(primary_address)
    @notice.primary_address = PdfTemplates::NoticeAddress.new({
      street_1: primary_address.address_1.titleize,
      street_2: primary_address.address_2.to_s.titleize,
      city: primary_address.city.titleize,
      state: primary_address.state,
      zip: primary_address.zip
      })
  end

  def append_enrollments(hbx_enrollments)
    hbx_enrollments.each do |hbx_enrollment|
      @notice.enrollments << PdfTemplates::Enrollment.new({
        plan_name: hbx_enrollment.plan.name,
        monthly_premium_cost: hbx_enrollment.total_premium,
        enrollees: hbx_enrollment.hbx_enrollment_members.inject([]) do |names, member| 
          names << member.person.full_name.titleize
        end
        }) 
    end 
  end
end
