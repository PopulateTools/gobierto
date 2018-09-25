import 'velocity-animate'
import 'velocity-ui-pack'

$(document).on('turbolinks:load', function() {
  $.Velocity.RegisterEffect("transition.slideLeftLongOut", { defaultDuration: 500, calls: [[ { opacity: [ 0, 1 ], translateX: -500, translateZ: 0 } ]],reset: { translateX: 0 }})
  $.Velocity.RegisterEffect("transition.slideLeftLongIn", { defaultDuration: 500, calls: [[ { opacity: [ 1, 0 ], translateX: [0,-500], translateZ: 0 } ]]})
  $.Velocity.RegisterEffect("transition.slideRightLongOut", { defaultDuration: 500, calls: [[ { opacity: [ 0, 1 ], translateX: 500, translateZ: 0 } ]],reset: { translateX: 0 }})
  $.Velocity.RegisterEffect("transition.slideRightLongIn", { defaultDuration: 500, calls: [[ { opacity: [ 1, 0 ], translateX: [0,500], translateZ: 0 } ]]})
});
