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

/**
 * Returns the metadata's endpoint of the dataset
 * @param {*} dataset Name of the source
 * @returns endpoint of the dataset's metadata
 */
export const getMetadataEndpoint = dataset => window.populateData.endpoint.replace(
  "data.json?sql=",
  `datasets/${dataset}/meta`
);

/**
 * NOTE: the place_id consists of five numbers,
 * where the first two are the province code, so,
 * to get the province average we need to filter
 * for all the elements sharing that numbers.
 *
 * Example:
 * when, city_id = 15500
 * then the province, place_id BETWEEN 15000 AND 15999
 */
export const getProvinceIds = city_id => {
  const lower = Math.trunc(parseInt(city_id) / 1e3) * 1e3
  const upper = Math.ceil(parseInt(city_id) / 1e3) * 1e3 - 1

  return [lower, upper]
}
