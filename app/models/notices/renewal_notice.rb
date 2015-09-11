module Notices
  class RenewalNotice < Notice

    def initialize(args = {})
      super
      @template = "notices/renewal_1b.html.erb"
    end

    def process
      generate_pdf_notice
      attach_blank_page
      attach_voter_registration
      generate_envelope
      prepend_envelope
      save_html
    end
  end
end
