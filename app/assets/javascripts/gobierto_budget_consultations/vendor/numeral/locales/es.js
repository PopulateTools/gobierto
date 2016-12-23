/*
 * numeral.js locale configuration
 * locale : spanish
 */
(function () {
    var numeral = typeof window !== 'undefined' ? this.numeral : require('../numeral');

    numeral.register('locale', 'es', {
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
