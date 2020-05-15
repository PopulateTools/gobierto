export function formatCurrency(amount) {
  if (amount === '' || amount === undefined) {
    return ''
  }

  return parseFloat(amount).toLocaleString(I18n.locale, {
    style: 'currency',
    currency: 'EUR'
  })
}
