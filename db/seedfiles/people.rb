puts "Loading People"

if Rails.env.development? || Rails.env.test? # don't wanna accidentally run this in prod. 
  FactoryGirl.create(:person)
  FactoryGirl.create(:under_26_person)
  FactoryGirl.create(:child_person)

  Person.all.each do |person|
    if person.authority_member.blank?
      person.authority_member = person.members.first
      person.save
    end
  end
end