# frozen_string_literal: true

module DiscourseMultiReactions::NotificationExtension
  def types
    @types_with_reaction ||= super.merge(reaction: 25)
  end
end
