import RawHtml from "discourse/widgets/raw-html";
import { emojiUnescape } from "discourse/lib/text";
import { h } from "virtual-dom";
import { createWidget } from "discourse/widgets/widget";

export default createWidget("discourse-multi-reactions-state-panel-reaction", {
  tagName: "div.discourse-multi-reactions-state-panel-reaction",

  click() {
    if (!this.capabilities.touch) {
      this.sendWidgetAction(
        "onChangeDisplayedReaction",
        this.attrs.reaction.id
      );
    }
  },

  touchStart() {
    if (this.capabilities.touch) {
      this.sendWidgetAction(
        "onChangeDisplayedReaction",
        this.attrs.reaction.id
      );
    }
  },

  buildClasses(attrs) {
    if (attrs.isDisplayed) {
      return "is-displayed";
    }
  },

  html(attrs) {
    return [
      h("span.count", attrs.reaction.count.toString()),
      new RawHtml({
        html: emojiUnescape(`:${attrs.reaction.id}:`)
      })
    ];
  }
});
