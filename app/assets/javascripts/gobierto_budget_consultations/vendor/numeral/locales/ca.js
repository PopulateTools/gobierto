/*
 * numeral.js locale configuration
 * locale : catalan
 */
(function () {
    var numeral = typeof window !== 'undefined' ? this.numeral : require('../numeral');

    numeral.register('locale', 'ca', {
        delimiters: {
            thousands: '.',
            decimal: ','
        },
        abbreviations: {
            million: 'M',
            billion: 'B',
            trillion: 'T'
        },
        currency: {
            symbol: '€'
        }
    });
}());
