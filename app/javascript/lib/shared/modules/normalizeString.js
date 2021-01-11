export function normalizeString(string) {
  let slug = string.normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/ /g, '-')
    .replace(/[.,()\s]/g, '')
    .toLowerCase();
  return slug
}
