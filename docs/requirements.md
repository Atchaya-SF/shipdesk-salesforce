# ShipDesk - Requirements and User Stories

**Project:** ShipDesk, an order and shipment support hub on Salesforce Service Cloud
**Version:** 1.0 (Phase 0)
**Status:** Draft for build

## 1. Business context

ShipDesk Retail sells online in three regions (NA, EMEA, APAC). Customers often ask where their order is, and some parcels are delayed or need to be returned. The support team works in Salesforce Service Cloud. A carrier system sends shipment status updates by API. The business wants delayed shipments to create cases automatically, regional SLAs to be applied consistently, and an AI agent to answer order-status questions.

## 2. Scope

**In scope:** Order and Shipment data model, case management with regional SLAs, automation (Flow and Apex), inbound and outbound REST integration, an Agentforce agent for order status and delay/return requests, reports and dashboards, release process and support runbook.

**Out of scope (version 1):** payments, inventory, a customer portal, live human chat handoff, real carrier APIs (a mock API is used).

## 3. Users

| Persona | Goal |
|---|---|
| Support Agent | Resolve order and delivery cases quickly |
| Support Manager | Meet SLAs and monitor team performance |
| Carrier System (integration) | Send shipment status updates securely |
| Customer | Get order status and report problems without waiting |

## 4. User stories and acceptance criteria

Priority: **M** = must have, **S** = should have.

### US1 - Order and shipments on one screen (M)
As a support agent, I want to see an order and all its shipments on one screen so that I can answer customers faster.

**Acceptance criteria**
- AC1.1: Given an Order with 2 shipments, when I open the Order record in the ShipDesk Console, then a Shipments related list shows both with Tracking Number, Carrier, Status and ETA.
- AC1.2: The Order highlights panel shows Status, Region and the count of delayed shipments (roll-up).

**Demo evidence:** screenshot of the Order page.

### US2 - Regional SLA due date (M)
As a support manager, I want each case to get an SLA due date based on its region so that the team knows when to respond.

**Acceptance criteria**
- AC2.1: Given a new case with Region = NA, when it is created, then SLA Due = creation time + 8 hours. EMEA = +12 hours. APAC = +24 hours.
- AC2.2: If a case is linked to an Order and Region is blank, Region is copied from the Order before the SLA is calculated.
- AC2.3: SLA hours are read from Custom Metadata (Region_Config__mdt), not hard-coded, so changing a value needs no code or flow edit.

**Demo evidence:** three cases (one per region) with SLA Due values; screenshot of the Custom Metadata records.

### US3 - Delayed shipment creates a case (M)
As the business, I want a delayed shipment to automatically create a high-priority case so that customers are helped before they complain.

**Acceptance criteria**
- AC3.1: Given a shipment with Status = In Transit, when its Status changes to Delayed, then exactly 1 case is created with Priority = High, Type = Delivery Issue, Origin = System, linked to the Order and Shipment.
- AC3.2: The case owner is the Delivery Issues queue (via the assignment rule).
- AC3.3: Saving the same Delayed shipment again does not create another case.
- AC3.4: Updating 200 shipments to Delayed in one transaction succeeds with no governor-limit error.
- AC3.5: The nightly batch marks In Transit or Out for Delivery shipments with ETA in the past as Delayed.

**Demo evidence:** case list view, Apex test results, batch run result.

### US4 - Resolution required to close a case (M)
As an agent, I must enter a resolution before closing a case so that the closure reason is always recorded.

**Acceptance criteria**
- AC4.1: Given an open case with Resolution blank, when I set Status = Closed and save, then I see the error "Enter a resolution before closing the case."
- AC4.2: With a Resolution filled in, the case closes successfully.
- AC4.3: A Return Request case cannot be saved without an Order.

**Demo evidence:** screenshot of the error and of a successful close.

### US5 - Secure shipment updates from the carrier (M)
As the carrier system, I can push status updates into Salesforce securely so that shipment data stays current.

**Acceptance criteria**
- AC5.1: Given a valid OAuth token for the integration user, when I POST {trackingNumber, status, eta} to /services/apexrest/shipments/v1/, then the matching shipment is updated and the response is 200.
- AC5.2: An invalid or missing token returns 401 and changes no data.
- AC5.3: An unknown tracking number returns 404.
- AC5.4: Malformed JSON returns 400 and writes a row to Integration_Log__c.
- AC5.5: The integration user has only the permissions it needs (API enabled, Shipment edit, Order read) and cannot log in through the UI.
- AC5.6: Setting Sync_Enabled__c = false in the Custom Setting stops outbound sync without a deployment.

**Demo evidence:** Postman or curl screenshots for 200, 401 and 404.

### US6 - Chat agent answers order status (M)
As a customer, I ask the chat agent for my order status and get accurate information so that I do not need to contact support.

**Acceptance criteria**
- AC6.1: The agent asks for the order number and the email on the order before looking anything up.
- AC6.2: With a matching order number and email, the agent returns order status, tracking number, shipment status and ETA.
- AC6.3: With a mismatching email, the agent says it cannot find a match and reveals no order data.
- AC6.4: For a late or returned parcel, the agent confirms the details, creates a case and gives the case number.
- AC6.5: The agent declines off-topic requests and attempts to bypass its rules.
- AC6.6: All 8 test utterances in the test plan pass in the Testing Center.

**Demo evidence:** Agentforce Builder preview recording and Plan Tracer screenshot.

### US7 - Manager dashboard (S)
As a manager, I want to track SLA breaches and delayed shipments in a dashboard so that I can act early.

**Acceptance criteria**
- AC7.1: The dashboard "Support Ops" shows SLA breaches by region and delayed shipments by carrier.
- AC7.2: It includes % of cases within SLA, open cases by region, and the 10 oldest open cases.
- AC7.3: A Region filter updates all components.

**Demo evidence:** dashboard screenshot.

## 5. Non-functional requirements

- **Security:** least-privilege permission sets, private org-wide defaults for Case, Order and Shipment, no secrets in code or in the repo.
- **Quality:** Apex test coverage of at least 90%, all automation bulk-safe.
- **Maintainability:** region settings stored in Custom Metadata, metadata tracked in Git.
- **Supportability:** errors logged to Integration_Log__c, runbook covers SEV-1 to SEV-3.

## 6. Assumptions and dependencies

- A Developer Edition org with Service Cloud features and Agentforce is available.
- A mock carrier API (for example Beeceptor or mockapi.io) is used for the outbound callout.
- A second Developer Edition org acts as UAT, since Developer Edition has no sandboxes.

## 7. Traceability

| Story | Built in phase |
|---|---|
| US1 | 3 (data model and pages) |
| US2 | 3 (Custom Metadata), 4 (Flow) |
| US3 | 4 (assignment rule), 5 (trigger and batch) |
| US4 | 4 (validation rules) |
| US5 | 2 (integration user), 6 (REST and OAuth) |
| US6 | 7 (Agentforce) |
| US7 | 8 (reports and dashboards) |

## 8. Sign-off checklist (UAT)

- [ ] US1 demonstrated
- [ ] US2 demonstrated
- [ ] US3 demonstrated
- [ ] US4 demonstrated
- [ ] US5 demonstrated
- [ ] US6 demonstrated
- [ ] US7 demonstrated
