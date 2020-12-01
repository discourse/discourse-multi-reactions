# frozen_string_literal: true

class RenameDiscourseReactionsReactionUsersToDiscourseMultiReactionsReactionUsers < ActiveRecord::Migration[6.0]
  def up
    begin
      Migration::SafeMigrate.disable!
      rename_table :discourse_reactions_reaction_users, :discourse_multi_reactions_reaction_users
    ensure
      Migration::SafeMigrate.enable!
    end
  end

  def down
    begin
      Migration::SafeMigrate.disable!
      rename_table :discourse_multi_reactions_reaction_users, :discourse_reactions_reaction_users
    ensure
      Migration::SafeMigrate.enable!
    end
  end
end
