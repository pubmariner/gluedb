class EdiIssues
  include Mongoid::Document

  embeds_many :edi_ops_transactions
  
end
