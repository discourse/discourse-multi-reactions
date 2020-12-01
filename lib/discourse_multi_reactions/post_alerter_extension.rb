# frozen_string_literal: true

module DiscourseMultiReactions::PostAlerterExtension
  def should_notify_previous?(user, post, notification, opts)
    super || (notification.notification_type == Notification.types[:reaction] && should_notify_like?(user, notification))
  end
end
