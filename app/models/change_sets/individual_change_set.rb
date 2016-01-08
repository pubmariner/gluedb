module ChangeSets
  class IndividualChangeSet
    attr_reader :resource, :record

    def initialize(remote_resource)
      @resource = remote_resource
      @individual_exists = remote_resource.exists?
      if @individual_exists
        @record = remote_resource.record
      end
    end

    def member
      @member ||= record.members.detect { |m| m.hbx_member_id == resource.hbx_member_id }
    end

    def individual_exists?
      @individual_exists
    end

    def create_individual_resource
    end

    def full_error_messages
      record.errors.full_messages
    end

    def has_active_policies?
    end

    def update_individual_record
    end

    def process_first_edi_change
    end

    def any_changes?
      change_count > 0
    end

    def multiple_changes?
      change_count > 1
    end

    def change_count
      @change_count ||= change_collection.count(&:itself)
    end

    def change_collection
      [
        contact_info_changed?,
        home_address_changed?,
        mailing_address_changed?,
        names_changed?,
        ssn_changed?,
        gender_changed?,
        dob_changed?
      ]
    end

    def contact_info_changed?
      emails_changed? || phones_changed?
    end

    def dob_changed?
      resource.dob != member.dob
    end

    def phones_changed?
      phone_has_changed?("home") ||
        phone_has_changed("work")
    end

    def emails_changed?
      email_has_changed?("home") ||
        email_has_changed?("work")
    end

    def home_address_changed?
      address_has_changed?("home")
    end

    def mailing_address_changed?
      address_has_changed?("mailing")
    end

    def names_changed?
      (resource.name_first != record.name_first) &&
        (resource.name_last != record.name_last) &&
        (resource.name_middle != record.name_middle) &&
        (resource.name_pfx != record.name_pfx) &&
        (resource.name_sfx != record.name_sfx)
    end

    def ssn_changed?
      resource.dob != member.ssn
    end

    def gender_changed?
      resource.gender != member.gender
    end

    protected

    def items_changed?(resource_item, record_item)
      return false if (resource_address.nil? && record_address.nil?)
      return true if record_address.nil?
      !record_address.match(resource_address)
    end

    def phone_has_changed?(phone_kind)
      resource_address = resource.phones.detect { |adr| adr.phone_type == phone_kind }
      record_address = record.phones.detect { |adr| adr.phone_type == phone_kind }
      items_changed?(resource_address, record_address)
    end

    def email_has_changed?(email_kind)
      resource_address = resource.emails.detect { |adr| adr.email_type == addy_kind }
      record_address = record.emails.detect { |adr| adr.email_type == addy_kind }
      items_changed?(resource_address, record_address)
    end

    def address_has_changed?(addy_kind)
      resource_address = resource.addresses.detect { |adr| adr.address_kind == addy_kind }
      record_address = record.addresses.detect { |adr| adr.address_type == addy_kind }
      items_changed?(resource_address, record_address)
    end
  end
end
