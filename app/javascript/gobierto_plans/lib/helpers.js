/**
 * Recursive calculation of depth levels in a object with children
 * @param {Array} Object with a children property
 */
export const depth = ({ children }) => 1 + (children.length ? Math.max(...children.map(depth)) : 0)