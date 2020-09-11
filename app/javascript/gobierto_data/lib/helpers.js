function getToken() {
  return window.gobiertoAPI.token.length == 0 && window.gobiertoAPI.basic_auth_token ? window.gobiertoAPI.basic_auth_token : window.gobiertoAPI.token
}

function getUserId() {
  return window.gobiertoAPI.current_user_id
}

function convertToCSV(arr) {
  const array = [Object.keys(arr[0])].concat(arr)

  return array.map(it => {
    return Object.values(it).toString()
  }).join('\n')
}

export { getToken, getUserId, convertToCSV }
