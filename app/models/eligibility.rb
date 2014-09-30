class Eligibility
  include Mongoid::Document
  include Mongoid::Timestamps

	field :determination_date, type: Date
  field :magi_in_cents, type: Integer, default: 0  # Modified Adjusted Gross Income
  field :max_aptc_in_cents, type: Integer, default: 0
  field :csr_percent, type: BigDecimal, default: 0.00   #values in DC: 0, .73, .87, .94

  field :receiving_es_coverage, type: Boolean # Employer-sponsored coverage
  field :is_without_assistance, type: Boolean
  field :financial_assistance, type: Boolean  # ???
  field :is_receiving_benefit, type: Boolean

  embedded_in :household

  validates_presence_of :determination_date, :max_aptc_in_cents, :csr_percent
  validate :csr_as_percent

  def magi_in_dollars=(dollars)
    self.magi_in_cents = Rational(dollars) * Rational(100)
  end

  def magi_in_dollars
    (Rational(magi_in_cents) / Rational(100)).to_f if magi_in_cents
  end

  def max_aptc_in_dollars=(dollars)
    self.max_aptc_in_cents = Rational(dollars) * Rational(100)
  end

  def max_aptc_in_dollars
    (Rational(max_aptc_in_cents) / Rational(100)).to_f if max_aptc_in_cents
  end

private
	# Validate csr_percent value is in range 1..0
  def csr_as_percent
		errors.add(:csr_percent, "value must be between 0 and 1") unless (0 <= csr_percent && csr_percent <= 1)
  end

end
