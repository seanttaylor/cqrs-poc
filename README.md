## Command Query Response Separation Pattern

## Purpose
To explore an architectural pattern ([Pipes & Filters](https://www.enterpriseintegrationpatterns.com/PipesAndFilters.html)) and a data access pattern ([Command Query Response Separation or CQRS](https://martinfowler.com/bliki/CQRS.html)) in order to discover what benefits they can provide when using high velocity/high volume streaming data sources.

## Local Development
1. Do `docker-compose` up
2. Do `cd /tf/local`
3. Do `terraform init`
4. Do `terraform plan`
5. Do `terraform apply --auto-approve`

These commands set up all the containers, launches Localstack and deploys the Terraform configuration against Localstack so that all the AWS resources in the configuration are available locally.

6. Do `docker restart edge_service` to restart the `edge_service` container running the application such that the Terraform-provisioned resources are now available.

### Helpful Commands
`export TF_LOG_PATH="./terraform.log"` exports Terraform logs to a structured log file

## Table of Contents
* [Overview](#overview)
* [Objective(s)](#objectives)
* [Architectural Notes](#architectural-notes)
* [References](#references)


## Overview <a name="overview"></a>
This project is part of an ongoing effort to explore decoupled system architectures to facilitate ease of up updating extending existing system components with new behaviors or features with minimal impact to the rest of the system.

Pipes & Filters is about processing streams of data, transforming the data as each 'filter' applies a set of operations on the data as it is in motion. An advantage of this design is that it allows us to add or remove operations (filters) to the pipes with ease, giving a highly composable architecture.

The Command Query Response Separation (CQRS) pattern see us separating write and read operations to our peristence layer such that 'commands' (i.e. writes, updates) and 'queries' are directed at two *separate* data stores. The Query data store is query-optimized, designed to best model the needs of clients querying for data about our system. 

The Query model may include additional fields or remove or reformat data in accordance with the query access patterns of our clients.

The Command model allows us to maintain a data store that represents the canonical or authoritative version of our data, here is where include all the fields on data model house data that may be pertinent to the records stored in this data store but not necessarily of interest or utility for querying clients.

Since we have a permanent record of all the commands issued to our system, it enables us to explore another pattern: that of Event Sourcing. If we frame our idea of the commands as events, we can then rebuild the system state to any point in the past all the way up to the present. 

Further, if we use an architecture like Pipes & Filters it allows us to change the past: to replay past events (commands) and apply different transformations (filters) to them to arrive at a completely new system state *or* a completely new system. 

## Objective(s) <a name="objectives"></a>
Create a system that has the following features:

| **Features**                                                                                                                          |
|---------------------------------------------------------------------------------------------------------------------------------------|
| Should be able to digest a continuous stream of events                                                                                |
| Should be able to apply various transformations to the event data by way of filters                                                   |
| Should be able to direct the result of transformations to specified sinks                                                             |
| Should be able to replay the stream of events and redirect the result of new transformations to different sinks                       |
| Should be able to add or remove transformations (filters) from the architecture with no downtime of the streaming pipeline as a whole |

## Architectural Notes <a name="architectural-notes"></a>
[ARCHITECTURAL NOTES GO HERE]

## References <a name="references"></a>
* [Pipes & Filters](https://www.enterpriseintegrationpatterns.com/PipesAndFilters.html) 
* [Command Query Response Separation](https://martinfowler.com/bliki/CQRS.html)
* [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)

