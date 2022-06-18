/* istanbul ignore file */

/**
* An object having the StreamingDatasource API; a set of methods for managing streaming data
* @typedef {Object} StreamingDatasourceAPI
* @property {Function} put - Puts a new item onto a data source
* @property {Function} pull - Starts consuming a data souce (e.g. a queue, stream REST endpoint)
*/

/**
 * Interface for a generic Datasource
 * @param {StreamingDatasourceAPI} myImpl - object defining concrete implementations for interface methods
 */

 function StreamingDatasource(myImpl) {
    if (!(this instanceof StreamingDatasource)) {
        return new StreamingDatasource(myImpl); 
    }

    function required() {
      throw Error('Missing implementation');
    }

    /**
      * @param {Object} config - configuration for the data source
      */
    this.init = myImpl.init || required;
  
    /**
      * @param {Object} entry - an entry for the data source to produce
      */
    this.put = myImpl.put || required;
  
    /**
      * 
      */
    this.pull = myImpl.pull || required;
    
  }
  
  export default StreamingDatasource