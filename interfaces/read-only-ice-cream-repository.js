/* istanbul ignore file */

/**
* An object having the ReadOnlyIceCreamRepository API; a set of methods for managing ice creams
* @typedef {Object} ReadOnlyIceCreamRepositoryAPI
* @property {Function} getIceCreamById - finds a ice cream in the data store by uuid
* @property {Function} getAllIceCreams - finds all ice creams in the data store
*/

/**
 * Interface for a repository of ice creams
 * @param {ReadOnlyIceCreamRepositoryAPI} myImpl - object defining concrete implementations for interface methods
 */

 function ReadOnlyIceCreamRepository(myImpl) {
    function required() {
      throw Error('Missing implementation');
    }
  
    /**
      @param {String} id - uuid of the ice cream
      @returns {IceCream} - the requested IceCream instance
      */
    this.getIceCreamById = myImpl.getIceCreamById || required;
  
    /**
      @returns {Array} - a list of all records in the data store
      */
    this.getAllIceCreams = myImpl.getAllIceCreams || required;
  }
  
  export default ReadOnlyIceCreamRepository