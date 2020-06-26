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
 * Find an item in a recursive structure by its ID
 * @param {*} arr Array to be iterated
 * @param {*} itemId Item id to be found
 */
export const findRecursive = (arr = [], itemId) => {
  let selected;
  arr.some((currentItem) => {
    return selected = currentItem.id === itemId ? currentItem : findRecursive(currentItem.children, itemId);
  });
  return selected;
}