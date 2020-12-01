# frozen_string_literal: true

module DiscourseMultiReactions
  class ReactionUser < ActiveRecord::Base
    self.table_name = 'discourse_multi_reactions_reaction_users'

    belongs_to :reaction, class_name: 'DiscourseMultiReactions::Reaction', counter_cache: true
    belongs_to :user

    delegate :username, to: :user, allow_nil: true
    delegate :avatar_template, to: :user, allow_nil: true

    def can_undo?
      self.created_at > SiteSetting.post_undo_action_window_mins.minutes.ago
    end
  end
end
