import IceCreamRepositoryInterface from "./interfaces/ice-cream-repository.js"
import ReadOnlyIceCreamRepositoryInterface from "./interfaces/read-only-ice-cream-repository.js"
import IceCreamRepository from "./lib/repo/ice-cream/index.js";
import InMemoryDatabaseConnector from "./lib/database/connectors/memory/index.js";

const inMemoryDatabaseConnector = new InMemoryDatabaseConnector();
const canonicalIceCreamRepository = new IceCreamRepository(inMemoryDatabaseConnector);
const canonicalIceCreamRepo = new IceCreamRepositoryInterface(canonicalIceCreamRepository);

/**
 * Creates a digest of an ice cream record
 * @param {Object} iceCreamData - data describing an ice cream
 */
function IceCreamDigest(iceCreamData) {

}

/**
 * Pushes the digest version of a canonical ice cream record to the query-only database
 * @param {Object} message 
 */
async function createDbRecordDigest(message) {
    const id = message.header.rel.id;
    const canonicalRecord = await canonicalIceCreamRepo.getIceCreamById(id);
    const digestRecord = IceCreamDigest(canonicalRecord);
    await queryOnlyRepo.create()
  }