/**
 * This Vue directives are widely used throughtout the application.
 * They're could be reused importing this module:
 *
 * import { VueDirectivesMixin } from "lib/shared";
 *
 * and then, in a Vue App, like so:
 *
 * mixins: [VueDirectivesMixin],
 *
 */
export const clickoutside = {
  bind(el, binding, vnode) {
    el.clickOutsideEvent = (event) => {
      if (!(el === event.target || el.contains(event.target))) {
        vnode.context[binding.expression](event);
      }
    };
    document.body.addEventListener('click', el.clickOutsideEvent)
  },
  unbind(el) { document.body.removeEventListener('click', el.clickOutsideEvent) },
  stopProp(event) { event.stopPropagation() }
}

export const VueDirectivesMixin = {
  directives: {
    clickoutside
  }
}
