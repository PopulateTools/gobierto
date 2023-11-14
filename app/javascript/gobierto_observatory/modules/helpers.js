/**
 * Returns an object whose keys are the different groups, i.e. the different values of the groupBy property
 * @param {Array} xs array element
 * @param {String} key property to be grouped by.
 */
export const groupBy = (xs, key) => xs.reduce((rv, x) => {
  (rv[x[key]] = rv[x[key]] || []).push(x);
  return rv;
}, {});

/**
 * Returns the shared metadata fields from the API response object (/meta)
 * @param {*} metadata API response
 * @returns Object source_name, description, frequency_type, updated_at
 */
export const getMetadataFields = metadata => ({
  source_name: metadata.data.attributes["dataset-source"],
  description: metadata.data.attributes.description,
  frequency_type:
    metadata.data.attributes.frequency[0].name_translations[
      I18n.locale
    ],
  updated_at: metadata.data.attributes.data_updated_at
})
