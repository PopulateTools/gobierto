import Appsignal from "@appsignal/javascript"
import { plugin } from "@appsignal/plugin-window-events"

const appsignal = new Appsignal({
  key: process.env.APPSIGNAL_PUSH_API_KEY
});

// https://docs.appsignal.com/front-end/plugins/plugin-window-events.html
appsignal.use(plugin())

export default appsignal;
