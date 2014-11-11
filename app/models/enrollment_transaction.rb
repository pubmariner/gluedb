class EnrollmentTransaction
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  field :kind, type: String
  field :ts_id, type: String
  field :ts_control_number, type: String
  field :sender, type: String
  field :receiver, type: String

  field :sponsor, type: String
  field :payer, type: String
  field :broker, type: String

  field :aasm_state, type: String

  field :effective_date, type: Date
  field :transmission

  embedded_in :policy

  index({ts_id: 1})
  index({:aasm_state => 1})


  aasm do
  	state :undetermined, initial: true
  	state :transmitted
  	state :received
  	state :transmit_ackd
  	state :transmit_nakd
  	state :receipt_ackd
  	state :receipt_nakd
  	state :resubmitted

  	event :transmit do
	    transitions from: :undetermined, to: :transmitted
	  end

	  event :receive do
	    transitions from: :undetermined, to: :received
		end

		event :acknowledge do
	    transitions from: :transmitted, to: :transmit_ackd
	    transitions from: :received, to: :receipt_ackd
	    transitions from: :resubmitted, to: :transmit_ackd
		end

		event :negative_acknowledge do
	    transitions from: :transmitted, to: :transmit_nakd
	    transitions from: :received, to: :receipt_nakd
	    transitions from: :resubmitted, to: :transmit_nackd
		end

    event :resubmit do
      transitions from: :transmit_nakd, to: :resubmitted
    end
	end


end
