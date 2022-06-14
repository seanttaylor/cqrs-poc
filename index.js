import { promisify } from "util";
import { Kafka } from "kafkajs";
import { of, map, interval, zip } from "rxjs";
import figlet from "figlet";

const KAFKA_BOOTSTRAP_SERVER = process.env.KAFKA_BOOTSTRAP_SERVER;

const figletize = promisify(figlet);
const myKafkaService = KafkaStreamService(KAFKA_BOOTSTRAP_SERVER);
const myIceCreamServiceClient = IceCreamServiceClient({console, streamService: myKafkaService});

/*** MAIN ***/
IceCreamService(myIceCreamServiceClient);

/**
 * 
 * @param {Object} console - an instance of the Console interface
 * @param {Object} streamService - an instance of the StreamService interface
 * @returns 
 */
function IceCreamServiceClient({console, streamService }) {

  async function init() {
    const banner = await figletize("soft-serve v.0.0.1");
    console.log(banner);
    /*try {
      await streamService.connect();
    } catch(e) {
      console.error(`IceCreamServiceClientError: ${e.message}`);
    }*/

    return {
      next,
      complete,
      error
    }
  }

  /**
   * 
   * @param {Object} message - an event message to push onto the Ice Cream pipeline 
   */
  function next(message) {
    console.log(message)
  }

  function complete() {

  }

  function error(e) {
    console.error(e);
  }

  return {init}
}

/**
 * 
 * @param {String} BOOTSTRAP_SERVER - the address of the Kafka bootstrap server
 */
function KafkaStreamService(BOOTSTRAP_SERVER) {
  let consumer;

  async function connect() {

    const kafka = new Kafka({
      clientId: 'ice_cream.edge_service',
      brokers: [`${BOOTSTRAP_SERVER}`],
    });
    consumer = kafka.consumer({ groupId: 'ice_cream' });
    await consumer.connect();
  };

  async function subscribe({ topic, onMessageFn }) {
    if (typeof (onMessageFn) !== 'function') {
      throw Error(`StreamService.BadRequest => onMessage must be of type function, not (${typeof onMessageFn})`);
    }
    await consumer.subscribe({ topic, fromBeginning: true });
    await consumer.run({
      eachMessage: onMessageFn,
    });
  };

  return { connect, subscribe}
}

/**
 * @param {Observer} client - an Observer subscribing to notifications from the MyIceCreamService  
 */
async function IceCreamService(client) {
  const myClient = await client.init();
  const sampleMessage = {
    header: {
      "eventId": "16421f41-de6f-4a90-b462-efb5a13eb174",
      "eventType": [
        "create"
      ],
      "eventName": [
          "create.ice_cream"
      ],
      "createdTimestamp": "2022-05-30T08:49:46.745Z",
      "detectionTimestamp": "2022-05-30T08:49:46.745Z",
      "rel": {
          "id": "205bdec2-036e-4e59-b930-34db01576434",
          "schemaVersion": "/schemas/ice_cream/messages/create/0.0.1",
          "next": "https://mylambdas.some.url-123456789"
      }
    },
    payload: {
      "name": "Vanilla Toffee Bar Crunch",
      "image_closed": "/files/live/sites/systemsite/files/flavors/products/us/pint/open-closed-pints/vanilla-toffee-landing.png",
      "image_open": "/files/live/sites/systemsite/files/flavors/products/us/pint/open-closed-pints/vanilla-toffee-landing-open.png",
      "description": "Vanilla Ice Cream with Fudge-Covered Toffee Pieces",
      "story": "Vanilla What Bar Crunch? We gave this flavor a new name to go with the new toffee bars we’re using as part of our commitment to source Fairtrade Certified and non-GMO ingredients. We love it and know you will too!",
      "sourcing_values": [
        "Non-GMO",
        "Cage-Free Eggs",
        "Fairtrade",
        "Responsibly Sourced Packaging",
        "Caring Dairy"
      ],
      "ingredients": [
        "cream",
        "skim milk",
        "liquid sugar (sugar",
        "water)",
        "water",
        "sugar",
        "coconut oil",
        "egg yolks",
        "butter (cream",
        "salt)",
        "vanilla extract",
        "almonds",
        "cocoa (processed with alkali)",
        "milk",
        "soy lecithin",
        "cocoa",
        "natural flavor",
        "salt",
        "vegetable oil (canola",
        "safflower",
        "and/or sunflower oil)",
        "guar gum",
        "carrageenan"
      ],
      "allergy_info": "may contain wheat, peanuts and other tree nuts",
      "dietary_certifications": "Kosher",
      "productId": "646"
    }
  };
  const myInterval$ = interval(1000);
  
  zip(myInterval$)
  .pipe(
    map(() => sampleMessage)
  ).subscribe(myClient);
};




