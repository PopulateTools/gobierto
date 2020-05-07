import axios from "axios";

export async function getRemoteData(endpoint) {
  const headers = { "Content-type": "text/csv" };

  return await axios.get(endpoint, { headers });
}
