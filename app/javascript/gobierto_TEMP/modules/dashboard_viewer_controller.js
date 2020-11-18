import Viewer from "../webapp/Viewer.vue"
// import "../../assets/stylesheets/module-TEMP-viewer.scss";
import { GobiertoDashboardCommonsController } from "./dashboard_commons_controller"

export class GobiertoDashboardViewerController extends GobiertoDashboardCommonsController {
  constructor(options = {}) {
    super({ ...options, render: h => h(Viewer) })
  }
}