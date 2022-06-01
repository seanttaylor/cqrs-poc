import { randomUUID } from "crypto";

/**
 * Adds system-specific metadata to messages before pushing to downstream pipes
 * @param {Object} message 
 * @returns 
 */
function enrichIncomingMessage(message) {
    const eventId = `events/${randomUUID()}`;
    const detectionTimestamp = new Date().toISOString();
    const enrichedHeader = Object.assign(message.header, {eventId, detectionTimestamp});
    const enrichedMessage = Object.assign(message, {header: enrichedHeader});
  
    return enrichedMessage;
  }