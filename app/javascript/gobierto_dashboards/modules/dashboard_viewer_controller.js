import Manager from "../webapp/Manager.vue"
import { GobiertoDashboardCommonsController } from "./dashboard_commons_controller"

export class GobiertoDashboardViewerController extends GobiertoDashboardCommonsController {
  constructor(options = {}) {
    super({ ...options, render: h => h(Manager) })
  }
}