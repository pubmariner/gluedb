module ExternalEvents
  module EnrollmentEventNotificationFilters
    class ZeroPremiumTotal
      def filter(enrollments)
        enrollments.reject do |en|
          en.drop_if_zero_premium_total!
        end
      end
    end
  end
end
