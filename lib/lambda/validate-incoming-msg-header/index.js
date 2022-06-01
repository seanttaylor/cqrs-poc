import Ajv from "ajv";
import messageHeaderSchema from "../../../schemas/message-header-v0.0.1.js" 

const ajv = new Ajv();

/**
 * Validates incoming message header data against an existing header schema
 * @param {Object} message 
 */
 function validateIncomingMessageHeader(message) {
    const {header} = message;
    const headerSchemaValidation = ajv.validate(messageHeaderSchema, header);
  
    if(!headerSchemaValidation) {
      console.error(ajv.errors)
      throw Error('ValidationError.invalidMessageHeader', ajv.errors);
    }
    return message;
  }