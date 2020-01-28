function getToken() {
  return window.gobiertoAPI.token
}

function getUserId() {
  return window.gobiertoAPI.current_user_id
}

export { getToken, getUserId }
