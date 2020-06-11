# frozen_string_literal: true

module DiscourseReactions::PostSerializerExtension
  def self.prepended(base)
    base.attributes :reactions
  end

  def reactions
    return false unless SiteSetting.discourse_reactions_enabled
    object.reactions.each_with_object({}) do |reaction, result|
      key = reaction.reaction_value
      result[key] = {
        id: key,
        type: reaction.reaction_type.to_sym,
        users: (result.dig(key, :users) || []) << { username: reaction.user.username, avatar_template: reaction.user.avatar_template },
        count: result.dig(key, :count).to_i + 1
      }
    end.values
  end
end
