
  /* istanbul ignore file */

//const Ajv = require('ajv');
//const ajv = new Ajv();
import dataTemplate from './template.js';

function InMemoryDatabaseConnector() {
  const data = { ...dataTemplate };
 
  /**
     * Add a document to the database.
     * @param {Object} doc - an instance of an entity DTO containing data to store
     * @param {String} collection - name of collection to add to
     * @returns {Object}
     */

  this.add = async function ({ doc, collection }) {
    if (typeof (doc) !== 'object') {
      throw new Error(`Record should be of type [Object] but is ${typeof (doc)} instead.`);
    }

    /*if (!Object.keys(this._schemaValidators).includes(collection)) {
      throw new Error(`InMemoryDatabaseConnectorError.AddError: collection (${collection}) does not exist`);
    }*/

    try {
      const record = doc.value();
      //const validate = ajv.compile(this._schemaValidators[collection]);

      /*if (!validate(record)) {
        throw new Error(`ValidationError.SchemaError: ${collection} ${JSON.stringify(validate.errors, null, 2)}`);
      }*/

      data[collection][record.id] = record;

      return [record];
    } catch (e) {
      console.error(`InMemoryDatabaseConnectorError: ${e.message}`);
      return undefined;
    }
  };

  /**
   * Update a document in the database by id
   * @param {Object} doc - an instance of an entity DTO containing data to store
   * @param {String} collection - collection to update
   * @returns {Object}
   */

  this.updateOne = async function ({ doc, collection }) {
    const { id } = doc.value();

    if (typeof (doc) !== 'object') {
      throw new Error(`Record should be of type [Object] but is ${typeof (doc)} instead.`);
    }

    if (!id) {
      throw new Error('InMemoryDatabaseConnectorError.UpdateError.MissingId');
    }

    /*if (!Object.keys(this._schemaValidators).includes(collection)) {
      throw new Error(`InMemoryDatabaseConnectorError.UpdateError: collection (${collection}) does not exist`);
    }*/

    if (!data[collection][id]) {
      console.info(`InMemoryDatabaseConnector.UpdateError: Could NOT find ${collection}.${id}`);
      return [];
    }

    try {
      //const validate = ajv.compile(this._schemaValidators[collection]);
      const record = Object.assign(doc.value(), {
        lastModified: new Date().toISOString(),
      });

      /*if (!validate(record)) {
        throw new Error(`ValidationError.SchemaError: ${collection} ${JSON.stringify(validate.errors, null, 2)}`);
      }*/

      data[collection][id] = record;
      return [record];
    } catch (e) {
      console.error('InMemoryDatabaseConnectorError:', e);
      return [];
    }
  };

  /**
   * Add a document to the database with a user-defined ID
   * @param {String} id - id of the document to create in the database
   * @param {Object} doc - an instance of an entity DTO containg data to store
   * @param {String} collection - collection to update
   * @returns {Object}
   */

  this.putOne = async function ({ doc, collection }) {
    const { id } = doc.value();

    if (typeof (doc) !== 'object') {
      throw new Error(`Record SHOULD be of type [Object] but is ${typeof (doc)} instead.`);
    }

    if (!id) {
      throw new Error('InMemoryDatabaseConnectorError.PutError.MissingId');
    }

    /*if (!Object.keys(this._schemaValidators).includes(collection)) {
      throw new Error(`InMemoryDatabaseConnectorError.PutError: Collection (${collection}) does NOT exist`);
    }*/

    try {
      //const validate = ajv.compile(this._schemaValidators[collection]);
      const record = doc.value();

      /*
      if (!validate(record)) {
        throw new Error(`ValidationError.SchemaError: (${collection}) ${JSON.stringify(validate.errors, null, 2)}`);
      }
      */

      data[collection][id] = record;
      return [record];
    } catch (e) {
      console.error(`InMemoryDatabaseConnectorError: ${e.message}`);
      return [];
    }
  };

  /**
   * Remove a document from a collection BY ID ONLY
   * @param {String} id - uuid of the document in the database
   * @param {String} collection - collection to remove from
   * @returns {Object}
   */

  this.removeOne = async function ({ id, collection }) {
    try {
      delete data[collection][id];
      return [];
    } catch (e) {
      console.error(e);
      return [];
    }
  };

  /**
   * Find all documents in a collection
   * @param {String} collection - collection to pull from
   * @returns {Object}
   */

  this.findAll = async function (collection) {
    try {
      return Object.values(data[collection]);
    } catch (e) {
      console.error(e);
      return [];
    }
  };

  /**
   * Find a document in a collection by uuid
   * @param {String} id - uuid of the document
   * @param {String} collection - collection to pull from
   * @returns {Object}
   */

  this.findOne = async function ({ id, collection }) {
    /*
    if (!Object.keys(this._schemaValidators).includes(collection)) {
      throw new Error(`InMemoryDatabaseConnectorError.FindOneError: Collection (${collection}) does not exist`);
    }
    */

    if (!id) {
      throw new Error('InMemoryDatabaseConnectorError.FindOneError.MissingId');
    }

    try {
      if (!data[collection][id]) {
        return [];
      }

      return [data[collection][id]];
    } catch (e) {
      console.error(e);
      return [];
    }
  };

  /**
   * Drop a collection from the database
   * @param {String} collection - collection to drop
   * @returns
   */

  this.drop = async function (collection) {
    delete data[collection];
    return [];
  };

  /**
   * Closes an existing connection to the database
   * This implementation does nothing as there is no database server connection
   * @returns
   */
  this.close = function () {
    return [];
  };
}

export default InMemoryDatabaseConnector;