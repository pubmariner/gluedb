require "rails_helper"

describe ::ExternalEvents::EnrollmentEventNotificationFilters::ZeroPremiumTotal, "given:
- an enrollment which has 0 premium total
- an enrollment which has > 0 premium total
" do

  let(:zero_premium_enrollment) { instance_double(ExternalEvents::EnrollmentEventNotification, :drop_if_zero_premium_total! => true) }
  let(:valid_enrollment) { instance_double(ExternalEvents::EnrollmentEventNotification, :drop_if_zero_premium_total! => false) }

  let(:events) { [zero_premium_enrollment, valid_enrollment] }

  it "filters out the zero premium action" do
    expect(subject.filter(events)).not_to include(zero_premium_enrollment)
  end

  it "keeps the valid action" do
    expect(subject.filter(events)).to include(valid_enrollment)
  end
end
