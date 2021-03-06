# frozen_string_literal: true

module DiscourseMultiReactions
  class ReactionNotification
    def initialize(reaction, user)
      @reaction = reaction
      @post = reaction.post
      @user = user
    end

    def create
      return if !enabled_reaction_notifications? ||
          DiscourseMultiReactions::Reaction
            .where(post_id: @post.id)
            .by_user(@user)
            .where('discourse_multi_reactions_reactions.created_at >= ?', 24.hours.ago)
            .count != 1
      PostAlerter.new.create_notification(@post.user, Notification.types[:reaction], @post, user_id: @user.id, display_username: @user.username)
    end

    def delete
      return if DiscourseMultiReactions::Reaction.where(post_id: @post.id).by_user(@user).count != 0
      read = true
      Notification.where(
        topic_id: @post.topic_id,
        user_id: @post.user_id,
        post_number: @post.post_number,
        notification_type: Notification.types[:reaction]
      ).each do |notification|
        read = false unless notification.read
        notification.destroy
      end
      refresh_notification(read)
    end

    private

    def enabled_reaction_notifications?
      @post.user.user_option.like_notification_frequency != UserOption.like_notification_frequency_type[:never]
    end

    def reaction_usernames
      @post.reactions
        .joins(:users)
        .order("discourse_multi_reactions_reactions.created_at DESC")
        .where('discourse_multi_reactions_reactions.created_at > ?', 1.day.ago)
        .pluck(:username)
    end

    def refresh_notification(read)
      return unless @post && @post.user_id && @post.topic

      usernames = reaction_usernames

      return if usernames.blank?

      data = {
        topic_title: @post.topic.title,
        username: usernames[0],
        display_username: usernames[0],
        username2: usernames[1],
        count: usernames.length
      }

      Notification.create(
        notification_type: Notification.types[:reaction],
        topic_id: @post.topic_id,
        post_number: @post.post_number,
        user_id: @post.user_id,
        read: read,
        data: data.to_json
      )
    end
  end
end
