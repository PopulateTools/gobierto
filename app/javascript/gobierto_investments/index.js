import { InvestmentsController } from "./modules/investments_controller.js";

$(document).on("turbolinks:load", function() {
  new InvestmentsController();
});
