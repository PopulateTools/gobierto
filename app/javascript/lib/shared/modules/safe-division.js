export default function divide(a, b, def = 0) {
  if (b === 0) return def
  return a / b
}
