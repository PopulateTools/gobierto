function getToken() {
  const HTMLString = document.getElementsByTagName('body')[0].innerHTML;
  const myRegexp = /token:(.*)/g;
  const match = HTMLString.match(myRegexp);
  const tokenString = match[1]
  const cleanToken = tokenString.replace(/token: "/g, '').replace(/"/g, '');

  return cleanToken
}

export default getToken;
