# frozen_string_literal: true

module DiscourseMultiReactions::GuardianExtension
  def can_delete_reaction_user?(reaction_user)
    reaction_user.can_undo?
  end
end
