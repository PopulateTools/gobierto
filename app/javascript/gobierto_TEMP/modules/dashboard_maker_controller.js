import Maker from "../webapp/Maker.vue"
// import "../../assets/stylesheets/module-TEMP-maker.scss";
import { GobiertoDashboardCommonsController } from "./dashboard_commons_controller"

export class GobiertoDashboardMakerController extends GobiertoDashboardCommonsController {
  constructor(options = {}) {
    super({ ...options, render: h => h(Maker) })
  }
}