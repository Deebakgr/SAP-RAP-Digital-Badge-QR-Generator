## 🪪 SAP RAP Digital Badge & QR Generator

## Enterprise Digital Credential Management Using SAP ABAP Cloud, RAP & Fiori Elements

## 📌 Project Overview

SAP RAP Digital Badge & QR Generator is an end-to-end enterprise web application developed using the **SAP RESTful Application Programming Model (RAP)** and **SAP Fiori Elements** to manage employee and visitor digital credentials efficiently.

The application enables users to manage badge information, maintain credential statuses, and dynamically generate scannable QR codes containing essential holder details. Built using an **Unmanaged RAP Scenario**, the application implements custom transactional handling, draft capabilities, and external API integration to deliver a responsive and enterprise-oriented credential management solution.

## 🎯 Key Features

- 🪪 **Digital Badge Management** – Create, update, and manage employee and visitor credentials.
- 📱 **Dynamic QR Code Generation** – Generate scannable QR codes using an external HTTP API.
- 🔗 **QR Code Payload Integration** – Embed Badge ID, Holder Name, Company, and Role into QR code data.
- 🗃️ **Unmanaged RAP Implementation** – Handle custom create, update, and delete operations through a dedicated implementation.
- 📝 **Draft Handling** – Support draft-based editing workflows.
- 🧩 **Root–Child Composition** – Connect badge header information with associated QR code data.
- 🔄 **Transactional Buffer Management** – Use a local buffer (`lcl_buffer`) to manage transactional changes.
- 📋 **Status Value Help** – Provide dropdown selection for badge statuses such as Active and Expired.
- 🖥️ **SAP Fiori Elements UI** – Deliver a responsive, metadata-driven user interface.
- 🔌 **OData V4 Service Integration** – Expose application functionality through an OData V4 service binding.

## 🏗️ Architecture & Technical Implementation

### 1. Unmanaged RAP Architecture

The application follows the **Unmanaged RAP programming model**, allowing custom implementation of transactional operations.

Core components include:

- `ZI_BADGE_HDR` – Root entity for digital badge information.
- `ZI_QR_DATA` – Child entity for QR code-related information.
- Composition relationship between root and child entities.
- Behavior definitions and behavior implementation classes.
- Projection views for exposing application-specific data.
- Local transactional buffer (`lcl_buffer`) for managing changes before persistence.

### 2. Dynamic QR Code Generation

The application includes a custom RAP action named `GenerateQRCode`, which can be triggered directly from the SAP Fiori Elements Object Page.

**Workflow:**

1. The user opens a digital badge record.
2. The user triggers the `GenerateQRCode` action.
3. The application prepares a QR payload containing badge and holder information.
4. A synchronous HTTP request is sent to an external QR code generation API.
5. The generated QR image is received as binary data.
6. The image is represented using `XSTRING` and stored in the database.

This integration connects SAP business application logic with an external service to generate QR codes dynamically.

### 3. Draft Handling & Transaction Management

Draft-enabled behavior supports editing workflows before changes are activated. The unmanaged implementation uses a local buffer pattern to coordinate transactional create, update, and delete operations.

This design provides greater control over business logic and data persistence.

### 4. Value Help & Fiori Elements UI

The application uses metadata-driven UI configuration to simplify credential management.

- `ZI_STATUS_VH` – Value help view for badge status selection.
- `#XS` size category – Configures a compact value help presentation.
- Metadata extensions – Define UI annotations and presentation behavior.
- OData V4 service binding – Exposes the application for Fiori Elements consumption.

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| SAP ABAP Cloud | Cloud-ready application development |
| SAP RAP | Business object modeling and transactional processing |
| CDS Views | Data modeling and semantic layer |
| Behavior Definitions | Business object behavior configuration |
| Behavior Implementation | Custom business logic |
| SAP Fiori Elements | Metadata-driven user interface |
| OData V4 | Service exposure and communication |
| HTTP Client Integration | External QR API communication |
| XSTRING | Binary QR image handling |
| Value Help Views | Status selection and user assistance |
| Metadata Extensions | UI annotations and layout configuration |

## 🔄 Application Workflow

```text
User
  |
  v
SAP Fiori Elements UI
  |
  v
OData V4 Service Binding
  |
  v
RAP Business Object
  |
  +----> Badge Header (ZI_BADGE_HDR)
  |
  +----> QR Data (ZI_QR_DATA)
  |
  v
GenerateQRCode Action
  |
  v
External QR Code API
  |
  v
QR Image (XSTRING)
  |
  v
Database Persistence
```

## 💡 Business Use Cases

- Employee identification and digital badge management.
- Visitor registration and credential issuance.
- QR-based retrieval of badge-related information.
- Centralized management of badge validity and status.
- Integration of SAP business processes with external QR generation services.

## 🚀 Learning Outcomes

Through this project, I gained practical experience in:

- Developing enterprise applications using SAP RAP.
- Implementing unmanaged business objects and custom transactional logic.
- Modeling root and child entities using CDS compositions.
- Working with draft-enabled application workflows.
- Creating custom RAP actions and integrating external HTTP APIs.
- Handling binary image data using `XSTRING`.
- Configuring value help, metadata extensions, and OData V4 services.
- Building responsive SAP Fiori Elements applications.

## 📂 Core Application Components

| Component | Description |
|---|---|
| `ZI_BADGE_HDR` | Root badge header entity |
| `ZI_QR_DATA` | Child QR data entity |
| `ZI_STATUS_VH` | Badge status value help |
| `lcl_buffer` | Local transactional buffer |
| `GenerateQRCode` | Custom QR generation action |
| Projection Views | Application-facing data models |
| Behavior Definitions | Transactional and business behavior |
| Metadata Extensions | Fiori UI annotations |
| OData V4 Service Binding | Service exposure for the UI |

## 🔐 Security & Data Considerations

- Validate badge and holder information before generating QR codes.
- Avoid embedding sensitive personal information directly in QR payloads unless necessary and authorized.
- Use secure communication when calling external APIs.
- Handle HTTP failures and invalid responses appropriately.
- Apply suitable authorization checks and access controls.
- Protect stored badge information and QR image data according to organizational policies.

## 📈 Future Enhancements

- QR code scanning and badge verification.
- Expiry notifications and automatic badge status updates.
- Role-based access control for badge administrators.
- QR code regeneration and revocation workflows.
- Integration with SAP identity and access management solutions.
- Enhanced reporting and badge lifecycle analytics.

## 👨‍💻 Project Summary

The **SAP RAP Digital Badge & QR Generator** demonstrates how SAP ABAP Cloud, the RESTful Application Programming Model, and SAP Fiori Elements can be combined to develop an enterprise-oriented digital credential management application.

By integrating custom unmanaged RAP logic, draft-enabled workflows, external QR code generation, and binary image persistence, the project showcases practical skills in SAP application development, service integration, and metadata-driven UI design.

---

## 📌 Project Information

- **Project Name:** SAP RAP Digital Badge & QR Generator
- **Domain:** SAP ABAP Cloud / Enterprise Application Development
- **Framework:** SAP RESTful Application Programming Model (RAP)
- **UI Technology:** SAP Fiori Elements
- **Architecture:** Unmanaged RAP with Root–Child Composition
- **Integration:** External QR Code Generation API
- **Service Protocol:** OData V4
