# frozen_string_literal: true

module DiscourseReactions::GuardianExtension
  def can_delete_reaction_user?(reaction_user)
    reaction_user.created_at > SiteSetting.post_undo_action_window_mins.minutes.ago
  end
end
