import 'velocity-animate'
import "../stylesheets/gobierto-plans.scss"

import { GobiertoPlansController } from "./modules/plan_types_controller";

document.addEventListener('DOMContentLoaded', () => {
  new GobiertoPlansController();

  $('.bread_hover').hover(function() {
    $('.bread_links a').attr('aria-expanded', true);
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function() {
    $('.bread_links a').attr('aria-expanded', false);
    $('.line_browser').velocity("fadeOut", { duration: 50 });
  });
});
