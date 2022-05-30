import "crypto"
import Ajv from "ajv";
import { of, map } from "rxjs";
import messageHeaderSchema from "./schemas/message-header-v0.0.1.js" 
import IceCreamRepositoryInterface from "./interfaces/ice-cream-repository.js"
//import ReadOnlyIceCreamRepositoryInterface from "./interfaces/read-only-ice-cream-repository.js"
import IceCreamRepository from "./lib/repo/ice-cream/index.js";
import InMemoryDatabaseConnector from "./lib/database/connectors/memory/index.js";

const inMemoryDatabaseConnector = new InMemoryDatabaseConnector();
const canonicalIceCreamRepository = new IceCreamRepository(inMemoryDatabaseConnector);
const canonicalIceCreamRepo = new IceCreamRepositoryInterface(canonicalIceCreamRepository);
//const queryOnlyRepo = new ReadOnlyIceCreamRepositoryInterface(canonicalIceCreamRepository);

const sampleMessage = {
  "eventType": [
    "create"
  ],
  "eventName": [
      "ice_cream.created"
  ],
  "createdTimestamp": "2022-05-30T08:49:46.745Z",
  "detectionTimestamp": "2022-05-30T08:49:46.745Z",
  "rel": {
      "id": "205bdec2-036e-4e59-b930-34db01576434",
      "schemaVersion": "/schemas/ice_cream/messages/create/0.0.1",
      "next": "https://mylambdas.some.url-123456789"
  }
};
const ajv = new Ajv();
const contentBasedMessageRouter = {
  "create.ice_cream": async function(message) { 
    const id = message.header.rel.id;
    const myIceCream = await canonicalIceCreamRepo.createIceCream({
      id, 
      doc: message.payload
    });
    const myIceCreamDigest = await digestIceCreamRepo.createIceCream({
      id, 
      doc: IceCreamDigest(myIceCream)
    });
    
    //TODO send event to email pipe
  },
  "update.ice_cream": async function(message) {
    const id = message.header.rel.id;
    const myIceCream = await canonicalIceCreamRepo.updateIceCream({
      id, 
      doc: message.payload
    });
    await digestIceCreamRepo.updateIceCream({
      id, 
      doc: IceCreamDigest(myIceCream)
    });
  }
}

/**
 * Validates incoming message header data against an existing header schema
 * @param {Object} message 
 */
function validateIncomingMessageHeader(message) {
  const {header} = message;
  const headerSchemaValidation = ajv.validate(messageHeaderSchema, header);

  if(!headerSchemaValidation) {
    throw Error('ValidationError.invalidMessageHeader', ajv.errors);
  }
  return message;
}

function enrichIncomingMessage(message) {
  const eventId = crypto.randomUUID();
  const detectionTimestamp = new Date().toISOString();
  const enrichedHeader = Object.assign(message.header, {eventId, detectionTimestamp});
  const enrichedMessage = Object.assign(message, {header: enrichedHeader});

  return enrichedMessage;
}

/**
 * Pushes messages to different downstream pipes based on message eventType (i.e. create or update)
 * @param {Object} message 
 */
function contentBasedRouterDbWrite(message) {

}

of([sampleMessage])
  //.pipe(map((x) => x * x))
  .subscribe((v) => console.log(v));