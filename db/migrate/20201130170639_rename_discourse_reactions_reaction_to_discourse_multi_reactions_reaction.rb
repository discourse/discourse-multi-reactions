# frozen_string_literal: true

class RenameDiscourseReactionsReactionToDiscourseMultiReactionsReaction < ActiveRecord::Migration[6.0]
  def up
    begin
      Migration::SafeMigrate.disable!
      rename_table :discourse_reactions_reactions, :discourse_multi_reactions_reactions
    ensure
      Migration::SafeMigrate.enable!
    end
  end

  def down
    begin
      Migration::SafeMigrate.disable!
      rename_table :discourse_multi_reactions_reactions, :discourse_reactions_reactions
    ensure
      Migration::SafeMigrate.enable!
    end
  end
end
