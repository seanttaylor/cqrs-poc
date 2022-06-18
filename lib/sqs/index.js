/**
 * 
 * 
 */
 function AWSSQSService() {
    let producer;
    let consumer;
  
    async function init() {
      //consumer = 
      //producer = 
      
    };
  
    /**
     * Initializes the consumer for subscriptions; connects to AWS SQS queue
     */
    async function initConsumer() {
      
    }
  
    /**
     * Initializes the producer for generating messages; connects to AWS SQS queue
     * 
     */ 
    async function initProducer() {
     
    }
  
    /**
     * Sends a message to the stream
     * @param {String} myMessage - message to add to the queue
     */
    async function producerSendMessage(myMessage) {
     
    }
  
    /**
     * 
     * @param {String} topic - stream topic to subscribe to
     * @param {Function} onMessageFn - a callback function to execute on receipt of new messages 
     */
    async function subscribe({ topic, onMessageFn }) {
      if (typeof (onMessageFn) !== 'function') {
        throw Error(`StreamService.BadRequest => onMessage must be of type function, not (${typeof onMessageFn})`);
      }
      await consumer.subscribe({ topic, fromBeginning: true });
      await consumer.run({
        eachMessage: onMessageFn,
      });
    };
  
    return { 
      init, 
      consumer: {
        init: initConsumer,
        subscribe,  
      },
      producer: {
        init: initProducer,
        send: producerSendMessage
      },
    }
  }