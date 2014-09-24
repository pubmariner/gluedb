class AddIncome
  def initialize(person_repo = Person, income_factory = Income)
    @person_repo = person_repo
    @income_factory = income_factory
  end

  def execute(request)
    person = @person_repo.find_by_id(request[:person_id])
    
    request[:incomes].each do |income_data|
      income = @income_factory.from_income_request(income_data)
      unless (person.incomes.any? { |i| i.same_as?(income) })
        person.incomes << income
        person.updated_by = request[:current_user]
        person.save!
      end
    end
  end  
end
