export default {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "http://example.com/example.json",
    "type": "object",
    "default": {},
    "title": "The event header schema",
    "required": [
        "eventType",
        "eventName",
        "createdTimestamp",
        "rel"
    ],
    "properties": {
        "eventId": {
            "$id": "#/properties/eventId",
            "type": "string",
            "title": "The eventId Schema",
            "description": "A uuid assigned to an event when ingresses into the system",
            "examples": [
                "205bdec2-036e-4e59-b930-34db01576434"
            ]
        },
        "eventType": {
            "$id": "#/properties/eventType",
            "type": "array",
            "title": "The eventType Schema",
            "description": "A name identifying the intent of the message (e.g create or read)",
            "items": {
                "type": "string",
                "enum": [
                    "create",
                    "update",
                    "delete"
                ]
            },
            "examples": [
                "create"
            ]
        },
        "eventName": {
            "$id": "#/properties/eventName",
            "type": "array",
            "title": "The eventName Schema",
            "description": "A plain text name of a specific group of events",
            "items": {
                "type": "string",
                "enum": [
                    "create.ice_cream",
                    "update.ice_cream",
                    "delete.ice_cream."
                ]
            },
            "examples": [
                "ice_cream.created"
            ]
        },
        "createdTimestamp": {
            "$id": "#/properties/createdTimestamp",
            "type": "string",
            "default": "",
            "title": "The createdTimestamp Schema",
            "description": "The timestamp of when the message is initially created",
            "examples": [
                "2022-05-30T08:49:46.745Z"
            ]
        },
        "detectionTimestamp": {
            "$id": "#/properties/detectionTimestamp",
            "type": "string",
            "default": "",
            "title": "The detectionTimestamp Schema",
            "description": "The timestamp of when the message was received by the system",
            "examples": [
                "2022-05-30T08:49:46.745Z"
            ]
        },
        "rel": {
            "$id": "#/properties/rel",
            "type": "object",
            "default": {},
            "title": "The rel Schema",
            "description": "A set of metadata related a specific message. Messages may or may not be part of long running operations or transactions",
            "required": [
                "id",
                "schemaVersion"
            ],
            "properties": {
                "id": {
                    "$id": "#/properties/rel/properties/id",
                    "type": "string",
                    "title": "The id Schema",
                    "description": "An identifier for an existing record, the intended identifier for a new record created by the client, or the identifier associated with a long running operation or transaction",
                    "examples": [
                        "205bdec2-036e-4e59-b930-34db01576434"
                    ]
                },
                "next": {
                    "$id": "#/properties/rel/properties/next",
                    "type": "string",
                    "title": "The next Schema",
                    "description": "The url of the next segment of the processing pipeline to push the message to",
                    "examples": [
                        "https://mylambdas.some.url-123456789"
                    ]
                },
                "schemaVersion": {
                    "$id": "#/properties/rel/properties/schemaVersion",
                    "type": "string",
                    "title": "The schemaVersion Schema",
                    "description": "The identifier for a schema to validate the message body against",
                    "examples": [
                        "/schemas/ice_cream/message/0.0.1"
                    ]
                }
            },
            "examples": [{
                "id": "205bdec2-036e-4e59-b930-34db01576434",
                "next": "https://mylambdas.some.url-123456789",
                "schemaVersion": "/schemas/ice_cream/message/0.0.1"
            }]
        }
    },
    "examples": [{
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
            "schemaVersion": "/schemas/ice_cream/message/create/0.0.1",
            "next": "https://mylambdas.some.url-123456789"
        }
    }]
}