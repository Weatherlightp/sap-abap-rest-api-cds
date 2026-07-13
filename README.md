# SAP Country Explorer

## Overview

This is a personal SAP S/4HANA project developed using ABAP Development Tools (ADT) in Eclipse.

The project demonstrates an end-to-end SAP ABAP backend application that consumes data from an external REST API, processes and transforms the JSON response, stores the data in custom SAP database tables and exposes it through CDS Views.

It is being developed as a personal learning project to gain hands-on experience with modern SAP development.

The application does the following steps:
- Retrieves country data from the REST Countries API
- Gets a JSON response
- Deserializes the JSON response into an ABAP structure
- Transforms nested data into a flat internal table
- Stores the data retrieved into custom database tables
- Exposing the data through CDS Views

The next planned milestone is exposing the CDS Views through an OData service and developing a SAP Fiori application to consume that service.

## Features

Current
- [x] Consume country data from the REST Countries API
- [x] Handle API pagination using limit and offset
- [x] Deserialize nested JSON into ABAP structures
- [x] Transform nested API data into a flat internal table
- [x] Persist data into custom SAP database tables
- [x] Expose the data through CDS Views

Planned
- [ ] OData Service
- [ ] SAP Fiori Application

## Project Architecture

```text
REST Countries API
        │
        ▼
HTTP Client
        │
        ▼
JSON Response
        │
        ▼
ZCL_COUNTRY_BUILD
        │
        ▼
Flat Internal Table
        │
        ▼
ZCL_COUNTRY_SAVE
        │
        ▼
Custom Database Tables 
(ZCOUNTRY1 / ZCOUNTRY_COORD)
        │
        ▼
ZI_COUNTRY1
(CDS View)
        │
 ┌──────┴─────────┐───────────────────┐
 ▼                ▼                   ▼
ZI_COUNTRY_BIG    ZI_COUNTRY_SIZE     Other CDS Views
```

## Project Structure

```text
src/
├── classes
│   ├── ZCL_COUNTRY_BUILD.abap
│   ├── ZCL_COUNTRY_SAVE.abap
│   └── ZCL_COUNTRY_ORCHESTRATOR.abap
│
├── cds
│   ├── ZI_COUNTRY1.ddls
│   ├── ZI_COUNTRY_BIG.ddls
│   └── ZI_COUNTRY_SIZE.ddls
│
└── dictionary
    ├── ZCOUNTRY1.md
    └── ZCOUNTRY_COORD.md
```

## Technologies

- SAP S/4HANA
- ABAP Cloud
- ABAP Development Tools (ADT)
- Eclipse
- REST APIs
- JSON
- SAP Dictionary
- CDS Views

## Screenshots

Later.
