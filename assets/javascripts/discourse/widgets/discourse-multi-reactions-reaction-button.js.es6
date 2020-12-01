import I18n from "I18n";
import { iconNode } from "discourse-common/lib/icon-library";
import { h } from "virtual-dom";
import { createWidget } from "discourse/widgets/widget";
import { later, cancel } from "@ember/runloop";

let _laterHoverHandlers = {};

export default createWidget("discourse-multi-reactions-reaction-button", {
  tagName: "div.discourse-multi-reactions-reaction-button",

  buildKey: attrs => `discourse-multi-reactions-reaction-button-${attrs.post.id}`,

  click() {
    this._cancelHoverHandler();

    if (!this.capabilities.touch) {
      this.callWidgetFunction("toggleLike");
    }
  },

  mouseOver(event) {
    this._cancelHoverHandler();

    if (!window.matchMedia("(hover: none)").matches) {
      _laterHoverHandlers[this.attrs.post.id] = later(
        this,
        this._hoverHandler,
        event,
        500
      );
    }
  },

  mouseOut() {
    this._cancelHoverHandler();

    if (!window.matchMedia("(hover: none)").matches) {
      this.callWidgetFunction("scheduleCollapse");
    }
  },

  buildAttributes(attrs) {
    let title;
    const likeAction = attrs.post.likeAction;

    if (!likeAction) {
      return;
    }

    if (likeAction.canToggle && !likeAction.hasOwnProperty("can_undo")) {
      title = "discourse_multi_reactions.main_reaction.add";
    }

    if (likeAction.canToggle && likeAction.can_undo) {
      title = "discourse_multi_reactions.main_reaction.remove";
    }

    if (!likeAction.canToggle) {
      title = "discourse_multi_reactions.main_reaction.cant_remove";
    }

    return { title: I18n.t(title) };
  },

  html(attrs) {
    const mainReactionIcon = this.siteSettings.discourse_multi_reactions_like_icon;
    const hasUsedMainReaction = attrs.post.current_user_used_main_reaction;
    const icon = hasUsedMainReaction
      ? mainReactionIcon
      : `far-${mainReactionIcon}`;

    return h(`button.btn-toggle-reaction.btn-icon.no-text`, [iconNode(icon)]);
  },

  _cancelHoverHandler() {
    const handler = _laterHoverHandlers[this.attrs.post.id];
    handler && cancel(handler);
  },

  _hoverHandler(event) {
    this.callWidgetFunction("cancelCollapse");
    this.callWidgetFunction("toggleReactions", event);
  }
});
