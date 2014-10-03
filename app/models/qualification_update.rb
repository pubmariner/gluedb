class QualificationUpdate
  KEYS = [:member_id, :citizen_status, :is_state_resident, :is_incarcerated]
  attr_accessor(*KEYS)

  def initialize(data = {})
    data.each_pair do |k, v|
      if KEYS.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
  end

  def member
    @member ||= Member.find_for_member_id(member_id)
  end

  def save!
    member.update_attributes!({
      :citizen_status => self.citizen_status,
      :is_state_resident => self.is_state_resident,
      :is_incarcerated => self.is_incarcerated
    })
  end
end
