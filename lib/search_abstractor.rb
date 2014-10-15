module SearchAbstractor


  class PeopleSearch

    def self.search(params)

      @@logger = Logger.new("#{Rails.root}/log/soap.log")

      @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

      clean_hbx_member_id = Regexp.new(Regexp.escape(params[:hbx_id].to_s))

      search = {'members.hbx_member_id' => clean_hbx_member_id}
      if(!params[:ids].nil? && !params[:ids].empty?)
        search['_id'] = {"$in" => params[:ids]}
      end

      @people = Person.where(search)

      page_number = params[:page]
      page_number ||= 1
      @people = @people.page(page_number).per(15)

    end
  end

  class PoliciesSearch

    def self.search(params)

      @@logger = Logger.new("#{Rails.root}/log/soap.log")

      @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

      clean_eg_id = Regexp.new(Regexp.escape(params[:enrollment_group_id].to_s))

      search = {"eg_id" => clean_eg_id}
      if(!params[:ids].nil? && !params[:ids].empty?)
        search['_id'] = {"$in" => params[:ids]}
      end

      @policies = Policy.where(search)

      page_number = params[:page]
      page_number ||= 1
      @policies = @policies.page(page_number).per(20)
    end
  end

end