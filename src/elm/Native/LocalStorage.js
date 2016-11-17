function stringify(value) {
  if (value && typeof value.toString === 'function') {
    return value.toString();
  }
  return null;
}

const _user$project$Native_LocalStorage = { // eslint-disable-line no-underscore-dangle, camelcase, max-len, no-unused-vars

  getItem: (key) => {
    const value = window.localStorage.getItem(key);
    console.log('Key: ', key, 'Value: ', JSON.stringify(value));
    return JSON.stringify(value);
  },

  setItem: ({ key, value }) => {
    window.localStorage.setItem(key, stringify(value));
    return value;
  },

};