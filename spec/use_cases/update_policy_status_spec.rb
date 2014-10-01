require './app/use_cases/update_policy_status'

describe UpdatePolicyStatus do
  class TestPolicy
    attr_accessor :aasm_state, :subscriber, :enrollees, :plan

    def initialize(aasm_state, subscriber, enrollees, plan)
      @aasm_state = aasm_state
      @subscriber = subscriber
      @enrollees = enrollees
      @plan = plan
    end

    def save
    end
  end

  subject { UpdatePolicyStatus.new(policy_repo) }

  let(:policy_repo) { double(find_by_id: policy) }
  let(:policy) { TestPolicy.new(current_status, subscriber, enrollees, plan) }
  let(:subscriber) { double(m_id: subscriber_id) }
  let(:subscriber_id) { '4321'}

  let(:plan) { double(hios_plan_id: hios_plan_id) }
  let(:hios_plan_id) { '123456789-01'}

  let(:enrollees) { double(count: 3) }
  let(:current_status) { 'effectuated' }
  let(:allowed_statuses) { ['effectuated', 'carrier_canceled', 'carrier_terminated'] }

  let(:listener) { double(policy_not_found: nil, invalid_dates: nil, policy_status_is_same: nil, fail: nil, success: nil) }

  let(:request) do
    {
      policy_id: '1234',
      status: requested_status,
      begin_date: begin_date,
      end_date: end_date,
      subscriber_id: requested_subscriber_id,
      enrolled_count: requested_enrollee_count,
      hios_plan_id: requested_hios_plan_id
    }
  end

  let(:requested_status) { 'carrier_terminated' }
  let(:begin_date) { Date.today.prev_year }
  let(:end_date) { Date.today }
  let(:requested_subscriber_id) { subscriber_id }
  let(:requested_enrollee_count) { enrollees.count }
  let(:requested_hios_plan_id) { hios_plan_id }


  it 'finds the policy' do
    expect(policy_repo).to receive(:find_by_id).with(request[:policy_id])
    expect(listener).not_to receive(:policy_not_found).with(request[:policy_id])
    subject.execute(request, listener)
  end

  it 'changes the policy status' do
    subject.execute(request, listener)
    expect(policy.aasm_state).to eq request[:status]
  end

  it 'saves the policy' do
    expect(policy).to receive(:save)
    subject.execute(request, listener)
  end

  it 'notifies listener of success' do
    expect(listener).to receive(:success)
    subject.execute(request, listener)
  end

  context 'requested status is same as current' do
    let(:requested_status) { current_status }

    it 'notifies the listener' do
      expect(listener).to receive(:policy_status_is_same)
      subject.execute(request, listener)
    end
  end

  context 'policy is not found' do
    let(:policy) { nil }
    it 'notifies a listener' do
      expect(listener).to receive(:policy_not_found).with(request[:policy_id])
      expect(listener).to receive(:fail)

      subject.execute(request, listener)
    end
  end

  context 'when requested subscriber id doesnt match' do
    let(:subscriber_id) { '1234'}
    let(:requested_subscriber_id) { '9999'}
    it 'notifies listener' do
      expect(listener).to receive(:subscriber_id_mismatch).with({provided: requested_subscriber_id, existing: subscriber_id})
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
  end

  context 'when enrollee count does not match' do
    let(:enrollee_count) { 3 }
    let(:requested_enrollee_count) { '99' }
    it 'notifies listener' do
      expect(listener).to receive(:enrolled_count_mismatch).with({provided: requested_enrollee_count, existing: enrollee_count})
      expect(listener).to receive(:fail)

      subject.execute(request, listener)
    end
  end

  context 'when plan does not match' do
    let(:hios_plan_id) { '123456789-01' }
    let(:requested_hios_plan_id) { '987654321-01' }

    it 'notifies listener' do
      expect(listener).to receive(:plan_mismatch).with({provided: requested_hios_plan_id, existing: hios_plan_id})
      expect(listener).to receive(:fail)

      subject.execute(request, listener)
    end
  end

  context 'status is canceled' do
    let(:requested_status) { 'carrier_canceled' }

    context 'requested begin date and end date are not equal' do
      let(:begin_date) { Date.today.prev_year }
      let(:end_date) { Date.today }

      it 'notifies the listener' do
        expect(listener).to receive(:invalid_dates).with(
          {
            begin_date: request[:begin_date],
            end_date: request[:end_date]
          }
        )
        expect(listener).to receive(:fail)

        subject.execute(request, listener)
      end
    end
  end

  context 'status is terminated' do
    let(:requested_status) { 'carrier_terminated' }
    context 'when begin and end date are equal' do
      let(:begin_date) { Date.today }
      let(:end_date) { Date.today }
      it 'notifies the listener' do
        expect(listener).to receive(:invalid_dates).with(
          {
            begin_date: request[:begin_date],
            end_date: request[:end_date]
          }
        )
        expect(listener).to receive(:fail)

        subject.execute(request, listener)
      end
    end
  end

  context 'when end date is before start date' do
    let(:begin_date) { Date.today }
    let(:end_date) { Date.today.prev_year }
    it 'notifies listener' do
      expect(listener).to receive(:invalid_dates).with(
        {
          begin_date: request[:begin_date],
          end_date: request[:end_date]
        }
      )
      expect(listener).to receive(:fail)

      subject.execute(request, listener)
    end
  end

  context 'when status is invalid' do
    let(:requested_status) { 'bingjiggitybong' }
    it 'notifies listener' do
      expect(listener).to receive(:invalid_status).with({provided: requested_status, allowed: allowed_statuses})
      subject.execute(request, listener)
    end
  end

  context 'when requested status is effectuated and was canceled/terminated' do
    let(:requested_status) { 'effectuated' }

    it 'sets the enrollee\'s end date' do
      
    end


  end

end
