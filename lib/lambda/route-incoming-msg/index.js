import IceCreamRepositoryInterface from "./interfaces/ice-cream-repository.js"
import ReadOnlyIceCreamRepositoryInterface from "./interfaces/read-only-ice-cream-repository.js"
import IceCreamRepository from "./lib/repo/ice-cream/index.js";
import InMemoryDatabaseConnector from "./lib/database/connectors/memory/index.js";

const inMemoryDatabaseConnector = new InMemoryDatabaseConnector();
const canonicalIceCreamRepository = new IceCreamRepository(inMemoryDatabaseConnector);
const canonicalIceCreamRepo = new IceCreamRepositoryInterface(canonicalIceCreamRepository);
const myContentBasedMessageRouter = ContentBasedMessageRouter({
    repository: canonicalIceCreamRepo,
});

/**
 * Routes messages according to the content of the message
 * @param {Object} repository 
 */
function ContentBasedMessageRouter({repository}) {
    async function createIceCream(message) {
        const myIceCream = await repository.create({
            id: message.header.rel.id,
            doc: message.payload
        });

        return myIceCream;
    }

    async function updateIceCream(message) {
        const myIceCream = await repository.editIceCreamName({
            id: message.header.rel.id,
            doc: message.payload
        });

        return myIceCream;
    }

    return {
        "create.ice_cream": createIceCream,
        "update.ice_cream": updateIceCream
    }
}

/**
 * Pushes messages to different downstream pipes based on message eventType (i.e. create or update)
 * @param {Object} message 
 */
 async function routeIncomingMessage(message) {
    const routeId = `${message.header.eventName[0]}`;
    const myIceCream = await myContentBasedMessageRouter[routeId](message);
    return myIceCream;
  }
  