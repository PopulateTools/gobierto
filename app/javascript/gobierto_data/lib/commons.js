export const baseUrl = `${location.origin}/api/v1/data`

export const CommonsMixin = {
  directives: {
    clickoutside: {
      bind: function(el, binding, vnode) {
        el.clickOutsideEvent = function(event) {
          if (!(el == event.target || el.contains(event.target))) {
            vnode.context[binding.expression](event);
          }
        };
        document.body.addEventListener('click', el.clickOutsideEvent)
      },
      unbind: function(el) {
        document.body.removeEventListener('click', el.clickOutsideEvent)
      },
      stopProp(event) { event.stopPropagation() }
    }
  }
}
