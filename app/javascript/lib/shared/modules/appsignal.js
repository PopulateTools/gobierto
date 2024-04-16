import Appsignal from "@appsignal/javascript"

export default new Appsignal({
  key: process.env.APPSIGNAL_PUSH_API_KEY
})
