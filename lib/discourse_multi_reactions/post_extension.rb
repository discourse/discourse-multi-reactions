# frozen_string_literal: true

module DiscourseMultiReactions::PostExtension
  def self.prepended(base)
    base.has_many :reactions, class_name: 'DiscourseMultiReactions::Reaction'
    base.attr_accessor :user_positively_reacted, :reaction_users_count
  end
end
