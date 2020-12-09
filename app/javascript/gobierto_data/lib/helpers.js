function getToken() {
  return window.gobiertoAPI.token
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
