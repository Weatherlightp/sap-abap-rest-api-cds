# SAP Country Explorer

## Overview

This is a personal SAP S/4HANA project developed using **ABAP Development Tools (ADT)** in Eclipse and the **SAP BTP ABAP Environment (Trial)**.

The project demonstrates an end-to-end SAP ABAP backend application that:
- Consumes country data from the REST Countries API
- Processes and transforms nested JSON responses
- Stores the data in custom SAP database tables
- Models the data using CDS Views
- Publishes an OData V4 service
- Presents the data through a SAP Fiori Elements application

The project was developed to gain hands-on experience with modern SAP development using SAP S/4HANA, ABAP Cloud, CDS Views, OData V4 and SAP Fiori Elements.



## Features

### Completed
- ✅ Consume country data from the REST Countries API
- ✅ Handle API pagination using **limit** and **offset**
- ✅ Deserialize nested JSON into ABAP structures
- ✅ Transform nested API data into a flat internal table
- ✅ Persist data into custom SAP database tables
- ✅ Model data using CDS Interface Views
  
- ✅ Create a CDS Consumption View
- ✅ Configure UI annotations using a Metadata Extension
- ✅ Expose data through an OData V4 Service Definition
- ✅ Publish the service using an OData V4 Service Binding
- ✅ Generate and preview a SAP Fiori Elements application


## Screenshots

### 1. SAP Fiori Elements – List Report (Initial Screen)

The application starts with a standard SAP Fiori Elements List Report where users can search and filter countries.

<img src="docs/01-fiori-list-report-empty.png" width="60%">

---

### 2. SAP Fiori Elements – Country List

Displaying the countries retrieved from the REST Countries API.

<img src="docs/02-fiori-list-report-results.png" width="60%">

---

### 3. Search and Filtering

Example of filtering the application by country name.

<img src="docs/03-fiori-filter-portugal.png" width="70%">

---

### 4. Object Page

Detailed country information generated automatically from CDS annotations and Metadata Extensions.

<img src="docs/04-fiori-object-page.png" width="70%">

---

### 5. OData V4 Service Binding

Service Binding used to publish the OData V4 service and preview the Fiori Elements application.

<img src="docs/05-service-binding.png" width="70%">

---

### 6. ABAP Development Tools Project Structure

Project organization inside Eclipse ADT.

![ADT Project](docs/06-adt-project-structure.png)

---

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
ABAP Classes
(Build / Save / Orchestrator)
        │
        ▼
Custom Database Tables 
(ZCOUNTRY1 / ZCOUNTRY_COORD)
        │
        ▼
Interface CDS View 
(ZI_COUNTRY1)                            
        │                                   
        ├────────────► ZI_COUNTRY_BIG
        ├────────────► ZI_COUNTRY_SIZE
        ├────────────► Possible additional CDS Views
        │
        ▼                                
Consumption CDS View                     
(ZC_COUNTRY1)                            
        │
        ▼
Metadata Extension
(ZC_COUNTRY1_MDE)
        │
        ▼
Service Definition
(ZUI_COUNTRY1)
        │
        ▼
Service Binding
(OData V4)
        │
        ▼
SAP Fiori Elements Preview
```

### Project Workflow

```text
1. Execute ZCL_COUNTRY_ORCHESTRATOR

2. ZCL_COUNTRY_ORCHESTRATOR
   • Calls ZCL_COUNTRY_BUILD to retrieve and process country data.
   • Calls ZCL_COUNTRY_SAVE to persist the processed data.

3. ZCL_COUNTRY_BUILD
   • Calls the REST Countries API.
   • Handles API pagination.
   • Deserializes the JSON response.
   • Flattens the nested data into an internal table.

4. ZCL_COUNTRY_SAVE
   • Stores the data into ZCOUNTRY1 and ZCOUNTRY_COORD database tables.

5. CDS Interface Views 
   • ZI_COUNTRY1 joins and models the persisted data.
   • Additional interface views (`ZI_COUNTRY_BIG` and `ZI_COUNTRY_SIZE`) demonstrate alternative data models.

6. CDS Consumption View
   • ZC_COUNTRY1
   • Defines the data exposed to the SAP Fiori Application.

7. Metadata Extension
   • ZC_COUNTRY1_MDE
   • Defines the Fiori Elements UI layout and annotations.

8. OData V4 Service
   • Service Definition (ZUI_COUNTRY1)
   • Service Binding (ZUI_COUNTRY1_BINDING)
   • Publishes the CDS Consumption View as an OData V4 service.

9. SAP Fiori Elements
   • List Report
   • Object Page
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
├── dictionary
│   ├── ZCOUNTRY1.md
│   └── ZCOUNTRY_COORD.md
│
├── consumption
│   ├── ZC_COUNTRY1.ddls
│   └── ZC_COUNTRY1_MDE.ddlx
│
├── service
│   ├── ZUI_COUNTRY1.srvd
│   └── ZUI_COUNTRY1_BINDING.txt
```

## Technologies

- SAP BTP ABAP Environment (Trial)
- SAP S/4HANA
- ABAP Cloud
- SAP ABAP Development Tools (ADT)
- Eclipse
- REST APIs
- HTTP Client
- JSON
- SAP Dictionary
- CDS Views
- Metadata Extensions
- OData V4
- SAP Fiori Elements
- Git
- GitHub


## Technical Highlights

- REST API consumption using the ABAP HTTP Client
- JSON deserialization using /UI2/CL_JSON
- API pagination handling
- Data persistence in custom SAP Dictionary tables
- CDS Interface and Consumption Views
- Metadata Extensions
- OData V4 Service Definition and Service Binding
- SAP Fiori Elements List Report and Object Page
