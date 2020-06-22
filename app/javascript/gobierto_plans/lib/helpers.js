/**
 * Recursive calculation of depth levels in a object with children
 * @param {Array} Object with a children property
 */
export const depth = ({ children }) =>
  1 + (children.length ? Math.max(...children.map(depth)) : 0);

/**
 * Recursive calculation of the number of children, grouped by depth level
 * @param {Array} arr Array with children props
 */
export const recursiveChildrenCount = arr => {
  const map = new Map();
  const counter = (arr = [], i = 0) => {
    // get the previous count number for a concrete level
    const currentCount = map.get(i) || 0;
    // add the new length found
    map.set(i, currentCount + arr.length);
    // repeat the calls for each children the object has, otherwise try to look at `children_count` property
    arr.map(({ children, attributes: { children_count = 0 } }) =>
      children.length
        ? counter(children, i + 1)
        : counter(Array(children_count), i + 1)
    );
  };
  // init the function
  counter(arr)
  return map;
};

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