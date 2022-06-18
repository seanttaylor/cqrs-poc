import { Kafka } from 'kafkajs';
import { randomUUID } from 'crypto';

/**
 * @implements {StreamingDatasourceAPI}
 * @param {String} BOOTSTRAP_SERVER - the address of the Kafka bootstrap server
 * @param {String} CLIENT_ID - the clientId of the Kafka application
 * @returns {Object} an implementation of the StreamingDatasourceAPI interface
 */
 function KafkaStreamingDatasource({BOOTSTRAP_SERVER, CLIENT_ID}) {
    let producer;
    let consumer;
  
    /**
     * @param {String} groupId - the groupId for a Kafka consumer
     * @param {String} as - whether the datasource will produce, consume or produce AND consume messages (defaults to both) valid values are: {producer|consumer}
     */
    async function init({groupId, as}) {
  
      const kafka = new Kafka({
        clientId: CLIENT_ID,
        brokers: [`${BOOTSTRAP_SERVER}`],
      });
      consumer = kafka.consumer({ groupId });
      producer = kafka.producer();

      if (!as) {
        //default setting; stream will both produce *AND* consume messages
        await consumer.connect();
        await producer.connect();
        return;
      }

      if (as === 'producer') {
        await producer.connect();
        return;
      }

      if (as === 'consumer') {
        await consumer.connect();
        return;
      }
  
    };
 
  
    /**
     * Sends a message to the stream
     * @param {String} topic - topic to put the message on
     * @param {String} message - message to add to the stream
     */
    async function put({topic, message}) {
      await producer.send({
        topic,
        messages: [ {key: randomUUID(), value: JSON.stringify(message) }],
      });
    }
  
    /**
     * 
     * @param {String} topic - stream topic to subscribe to
     * @param {Function} onMessage - a callback function to execute on receipt of new messages 
     */
    async function pull({ topic, onMessage }) {
      if (typeof (onMessage) !== 'function') {
        throw Error(`StreamService.BadRequest => onMessage must be of type function, not (${typeof onMessage})`);
      }
      await consumer.subscribe({ topic, fromBeginning: true });
      await consumer.run({
        eachMessage: onMessage,
      });
    };
  
    return { 
      init,
      put,
      pull,
    }
  }

  export default KafkaStreamingDatasource