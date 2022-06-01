/* istanbul ignore file */

/**
* An object having the IceCreamRepository API; a set of methods for managing ice creams
* @typedef {Object} IceCreamRepositoryAPI
* @property {Function} create - creates a new ice cream in the data store
* @property {Function} getIceCreamById - finds a ice cream in the data store by uuid
* @property {Function} editIceCreamName - updates the `name` propery of an existing ice cream
* @property {Function} getAllIceCreams - finds all ice creams in the data store
* @property {Function} deleteIceCream - deletes a ice cream in the data store by its uuid
*/

/**
 * Interface for a repository of ice creams
 * @param {IceCreamRepositoryAPI} myImpl - object defining concrete implementations for interface methods
 */

 function IceCreamRepository(myImpl) {
    function required() {
      throw Error('Missing implementation');
    }
  
    /**
      @param {Object} doc - object representing a valid entry
      @returns {String} - a uuid for the new ice cream
      */
    this.create = myImpl.create || required;
  
    /**
      @param {String} id - uuid of the ice cream
      @returns {IceCream} - the requested IceCream instance
      */
    this.getIceCreamById = myImpl.getIceCreamById || required;
  
    /**
      @returns {Array} - a list of all records in the data store
      */
    this.getAllIceCreams = myImpl.getAllIceCreams || required;
    
    /**
      @param {String} id - uuid of the IceCream
      */
    this.editIceCreamName = myImpl.editIceCreamName || required;

    /**
      @param {String} id - uuid of the IceCream
      @param {String} name - updated name of the IceCream
      */
    this.deleteIceCream = myImpl.deleteIceCream|| required;
  
  }
  
  export default IceCreamRepository