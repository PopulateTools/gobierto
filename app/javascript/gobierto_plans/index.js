import './modules/application.js'

import "../../assets/stylesheets/module-planification.scss"
// TODO: convert to css variables
import "../../assets/stylesheets/module-planification-custom.scss"

import { GobiertoPlansController } from "./modules/plan_types_controller";

document.addEventListener('DOMContentLoaded', () => new GobiertoPlansController());
