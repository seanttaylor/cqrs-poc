/* istanbul ignore file */

/* Implements IIceCreamRepository interface for connecting to a datastore.
See interfaces/ice-cream-repository for method documentation */

/**
 * @implements {IIceCreamRepository}
 * @param {Object} databaseConnector - object with methods for connecting to a database
 */

 function IceCreamRepository(databaseConnector) {
    this.create = async function (doc) {
      const [record] = await databaseConnector.add({
        doc,
        collection: 'ice_creams',
      });
  
      return { id: record.id, createdDate: record.createdDate };
    };
  
    this.getIceCreamById = async function (id) {
      const [record] = await databaseConnector.findOne({ id, collection: 'ice_creams' });
      return record;
    };
  
    this.editIceCreamName = async function (doc) {
      await databaseConnector.updateOne({
        doc,
        collection: 'ice_creams',
      });
    };

    this.deleteIceCream = async function (id) {
      await databaseConnector.removeOne({ id, collection: 'ice_creams' });
    };
  }
  
  /* IceCreamRepository */
  
  export default IceCreamRepository;
