class ImportCuramData

  def initialize(app_group_repo, person_finder, person_factory, app_group_factory, relationship_factory, qualification_factory, assistance_eligibilities_importer)
    @app_group_repo = app_group_repo
    @person_finder = person_finder
    @person_factory = person_factory
    @app_group_factory = app_group_factory
    @relationship_factory = relationship_factory
    @qualification_factory = qualification_factory
    @assistance_eligibilities_importer = assistance_eligibilities_importer
  end

  def qualified_member(person_properties, person)
      [ 
        person.members.detect { |m| m.hbx_member_id == person_properties[:member_id] },
        person.authority_member, 
        person.members.first
      ].detect { |m| !m.nil? }
  end

  def execute(request)
    app_group = @app_group_repo.find_by_case_id(request[:e_case_id])
    if(app_group)
      app_group.destroy!
    end

    mapped_people = {}
    request[:people].each do |p_hash|
      person = @person_finder.find(p_hash) # Doesn't currently search by member id as far as we know
      if(person.nil?)
        person = @person_factory.create!(p_hash)
      end
      mapped_people[p_hash[:id]] = person
      
      member_id = qualified_member(p_hash, person).hbx_member_id
      @qualification_factory.new(
        {
          :member_id => member_id,
          :is_incarcerated => p_hash[:is_incarcerated],
          :is_state_resident => p_hash[:is_state_resident],
          :citizen_status => p_hash[:citizen_status]
      }).save!
      @assistance_eligibilities_importer.import!(
        person,
        Array(p_hash[:assistance_eligibilities])
      )
    end

    @app_group_factory.create!({
        :e_case_id => request[:e_case_id],
        primary_applicant_id: mapped_people[request[:primary_applicant_id]].id,
        submission_date: request[:submission_date],
        people: mapped_people.values
      })
    request[:relationships].each do |rel|
      @relationship_factory.new({
          :subject_person_id => mapped_people[rel[:subject_person]].id,
          :relationship_kind => rel[:relationship_kind],
          :object_person_id => mapped_people[rel[:object_person]].id
        }).save!
    end
  end
end

describe ImportCuramData do
  subject { ImportCuramData.new(app_group_repo, person_finder, person_factory, app_group_factory, relationship_factory, qualification_factory, assistance_eligibilities_importer) }
  let(:app_group_repo) { double(find_by_case_id: app_group) }
  let(:app_group) { double(destroy!: nil) }
  let(:person_finder) { 
    finder = double
    allow(finder).to receive(:find).with(person_properties).and_return(person)
    allow(finder).to receive(:find).with(child_properties).and_return(child)
    finder
  }
  let(:person_factory) { double(create!: person)}
  let(:app_group_factory) { double(create!: nil)  }
  let(:person) { double(:id => person_id, :members => [], :authority_member => authority_member) }
  let(:app_group_properties) {
     {
      e_case_id: case_id,
      primary_applicant_id: person_id,
      people: [person, child],
      submission_date: submission_date
     }
   }
  let(:submission_date) { Date.today }
  let(:person_id) { "abcde" }
  let(:case_id) { "1234" }
  let(:applicant_id) { 'franks id' }
  let(:request) do
    {
      e_case_id: case_id,
      primary_applicant_id: applicant_id,
      submission_date: submission_date,
      people: [
       person_properties,
       child_properties
      ],
      relationships:  [
        {:subject_person => child_applicant_id, :relationship_kind => relationship_kind, :object_person => applicant_id }
      ]
    }
  end

  let(:authority_member) { double(:hbx_member_id => member_id) }
  let(:child_authority) { double(:hbx_member_id => child_id) }

  let(:child) { double(:id => child_id, :members => [], :authority_member => child_authority) }
  let(:child_properties) { { id: child_applicant_id } }
  let(:child_applicant_id) { "klsjdflkdf" }
  let(:child_id) { "a child id" }
  let(:relationship_kind) { "child of" }
  let(:relationship_update) { double(save!: nil) }
  let(:relationship_factory) { double(new: relationship_update)}
  let(:person_properties) do
    {
      :id => applicant_id,
      :dob => "frank",
      :citizen_status => citizen_status,
      :is_state_resident => is_state_resident,
      :is_incarcerated => is_incarcerated,
      :assistance_eligibilities => assistance_eligibilities
    }
  end

  let(:qualification_factory) { double(:new => qualification_update) }
  let(:qualification_update) { double(:save! => nil) }
  let(:member_id) { "a member id" }
  let(:citizen_status) { "nope" }
  let(:is_incarcerated) { "yup" }
  let(:is_state_resident) { "maybe, I guess.  Define 'state'."}

  it 'finds an application group by case number' do
    expect(app_group_repo).to receive(:find_by_case_id).with(request[:e_case_id]).and_return(app_group)
    subject.execute(request)
  end

  it "should update relationships" do
    expect(relationship_factory).to receive(:new).with(
      :subject_person_id => child_id,
      :object_person_id => person_id,
      :relationship_kind => relationship_kind
    ).and_return(relationship_update)
    expect(relationship_update).to receive(:save!)
    subject.execute(request)
  end

  context 'when application group exists' do
    it "is deleted" do
      expect(app_group).to receive(:destroy!)
      subject.execute(request)
    end
  end

  it "creates the application group" do
    expect(app_group_factory).to receive(:create!).with(app_group_properties)
    subject.execute(request)
  end

  it "updates the member qualifications" do
    expect(qualification_factory).to receive(:new).with(
      :member_id => member_id,
      :citizen_status => citizen_status,
      :is_state_resident => is_state_resident,
      :is_incarcerated => is_incarcerated
    ).and_return(qualification_update)
    expect(qualification_update).to receive(:save!)
    subject.execute(request)
  end

  context "when a person exists" do
    before(:each) do
      allow(person_finder).to receive(:find).with(person_properties).and_return(person)
    end

    it 'does not create that person' do
      expect(person_factory).not_to receive(:create!).with(person_properties)
      subject.execute(request)
    end
  end

  context "when a person doesn't exist" do
    before(:each) do
      allow(person_finder).to receive(:find).with(person_properties).and_return(nil)
    end

    it "should create that person" do
      expect(person_factory).to receive(:create!).with(person_properties)
      subject.execute(request)
    end
  end

  let(:assistance_eligibilities_importer) { double(import!: nil) }
  let(:assistance_eligibilities) { [double] }
  it 'should import the assistance eligibility information' do
    expect(assistance_eligibilities_importer).to receive(:import!).with(
      person,
      assistance_eligibilities
    )
    expect(assistance_eligibilities_importer).to receive(:import!).with(
      child,
      []
    )
    subject.execute(request)
  end

  # it "creates a new application group" do
  #   expect(app_group_factory).to receive(:create).with(request)
  #   subject.execute(request)
  # end


  # it 'identifies or creates the people in the import'

  # it 'places the proper members into a properly structured household'

  # it 'creates the correct relationships'

  # it 'assigns the right income, benefit, and deduction data'
end








