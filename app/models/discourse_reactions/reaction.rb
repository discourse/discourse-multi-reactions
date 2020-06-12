# frozen_string_literal: true

module DiscourseReactions
  class Reaction < ActiveRecord::Base
    self.table_name = 'discourse_reactions_reactions'

    enum reaction_type: { emoji: 0 }

    belongs_to :user
    belongs_to :post

    def self.valid_reactions
      SiteSetting.discourse_reactions_enabled_reactions.split(/\|-?/)
    end
  end
end
