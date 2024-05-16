function getUserId() {
  return window.gobiertoAPI.current_user_id
}

function convertToCSV(arr) {
  const array = [Object.keys(arr?.[0] || {})].concat(arr)

  return array.map(it => Object.values(it).toString()).join('\n')
}

export { getUserId, convertToCSV }
