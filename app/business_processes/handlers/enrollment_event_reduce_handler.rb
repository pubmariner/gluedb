module Handlers
  class EnrollmentEventReduceHandler < Base
    
    # call :: [::ExternalEvents::EnrollmentEventNotification]-> [[::ExternalEvents::EnrollmentEventNotification]]
    # We split out and collate the events into buckets.  Then we call the step after us once for each bucket.
    def call(context)
      no_rerun_terms = execute_filters(context)
      reduced_list = perform_reduction(no_rerun_terms)
      reduced_list.map do |element|
#        begin
          super(element)
#        rescue
          # Add error information to duplicated context
#        end
      end
    end

    protected

    def execute_filters(enrollments)
      filters = [
        ::ExternalEvents::EnrollmentEventNotificationFilters::AlreadyProcessedEvent.new,
        ::ExternalEvents::EnrollmentEventNotificationFilters::TerminationWithoutEnd.new,
        ::ExternalEvents::EnrollmentEventNotificationFilters::AlreadyProcessedTermination.new,
        ::ExternalEvents::EnrollmentEventNotificationFilters::ZeroPremiumTotal.new
      ]
      filters.inject(enrollments) do |acc, filter|
        filter.filter(acc)
      end
    end

    def perform_reduction(full_event_list)
      duplicate_filter = ::ExternalEvents::EnrollmentEventNotificationFilters::RemoveSameActionsAndSelectSilent.new
      event_list = duplicate_filter.filter(full_event_list)
      event_list.combination(2).each do |a, b|
        if a.hash == b.hash
          a.check_and_mark_duplication_against(b)
        end
      end
      dropped, free_of_dupes  = event_list.partition(&:drop_if_marked!)
      # GC hint
      dropped = nil
      free_of_dupes.group_by(&:bucket_id).values
    end
  end
end
