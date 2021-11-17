import "../../stylesheets/gobierto-dashboards-viewer.scss"
import ViewerManager from "../webapp/ViewerManager.vue"
import { GobiertoDashboardCommonsController } from "./dashboard_commons_controller"

export class GobiertoDashboardViewerController extends GobiertoDashboardCommonsController {
  constructor(options = {}) {
    super({ ...options, render: h => h(ViewerManager) })
  }
}
