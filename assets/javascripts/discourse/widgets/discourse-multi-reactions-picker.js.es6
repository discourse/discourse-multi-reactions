import RawHtml from "discourse/widgets/raw-html";
import { emojiUnescape } from "discourse/lib/text";
import { h } from "virtual-dom";
import { createWidget } from "discourse/widgets/widget";

export default createWidget("discourse-multi-reactions-picker", {
  tagName: "div.discourse-multi-reactions-picker",

  buildKey: attrs => `discourse-multi-reactions-picker-${attrs.post.id}`,

  mouseOut() {
    if (!window.matchMedia("(hover: none)").matches) {
      this.callWidgetFunction("scheduleCollapse");
    }
  },

  mouseOver() {
    if (!window.matchMedia("(hover: none)").matches) {
      this.callWidgetFunction("cancelCollapse");
    }
  },

  html(attrs) {
    if (attrs.reactionsPickerExpanded) {
      return [
        h(
          "div.container",
          attrs.post.topic.valid_reactions.map(reaction => {
            let isUsed;
            let canUndo;
            if (
              reaction ===
              this.siteSettings.discourse_multi_reactions_reaction_for_like
            ) {
              isUsed = attrs.post.current_user_used_main_reaction;
              canUndo =
                attrs.post.likeAction &&
                ((isUsed && attrs.post.likeAction.canToggle) || !isUsed);
            } else {
              isUsed = attrs.post.current_user_reactions.findBy("id", reaction);
              canUndo = !isUsed || isUsed.can_undo;
            }

            let title;
            let titleOptions;
            if (canUndo) {
              title = "discourse_multi_reactions.picker.react_with";
              titleOptions = { reaction };
            } else {
              title = "discourse_multi_reactions.picker.cant_remove_reaction";
            }

            return this.attach("button", {
              action: "toggleReaction",
              data: { reaction },
              actionParam: { reaction, postId: attrs.post.id, canUndo },
              className: `pickable-reaction ${reaction} ${
                canUndo ? "can-undo" : ""
              } ${isUsed ? "is-used" : ""}`,
              title,
              titleOptions,
              contents: [
                new RawHtml({
                  html: emojiUnescape(`:${reaction}:`)
                })
              ]
            });
          })
        )
      ];
    }
  }
});
