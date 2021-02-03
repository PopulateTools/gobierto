export function slugString(string) {
  return string
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "") // remove accents
    .replace(/ /g, "-") // turn spaces into dashes
    .replace(/[^A-Z0-9-]/gi, "") // remove everything but letters, numbers and dashes; case insensitive
    .toLowerCase();
}
