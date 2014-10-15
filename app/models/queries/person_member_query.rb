module Queries
  class PersonMemberQuery
    def initialize(m_ids)
      @member_ids = m_ids
    end

    def query
      {
        "members" => {
          "$elemMatch" => {
            "hbx_member_id" => { "$in" => @member_ids }
          }
        }
      }
    end

    def execute
      Person.unscoped.where(query)
    end
  end
end
