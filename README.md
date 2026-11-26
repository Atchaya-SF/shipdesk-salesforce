# ShipDesk: E-Commerce Order & Shipment Support Hub

An end-to-end multi-region customer service solution built on **Salesforce Service Cloud**. ShipDesk centralizes support operations across **NA, EMEA, and APAC** by combining declarative automation, bulkified Apex, OAuth-secured REST integrations, and an **Agentforce** service agent.

## Key Capabilities & Architecture

* **Multi-Region Service Cloud Design:** Built custom `Order__c` and `Shipment__c` objects, Case record types, regional queues, assignment rules, and dynamic SLA deadlines driven by `Region_Config__mdt` Custom Metadata (`NA` +8h, `EMEA` +12h, `APAC` +24h).
* **Declarative & Apex Automation:** Automated case handling with Before-Save, After-Save, Screen, and Scheduled Flows alongside a bulkified `ShipmentTrigger`, nightly `OverdueShipmentBatch`, and SOQL/SOSL search services—backed by Apex unit tests achieving **90%+ code coverage**.
* **Bi-Directional REST Integrations:** Built an outbound carrier tracking callout via Named Credentials (`CarrierApiService`) and an OAuth 2.0 Client Credentials inbound REST endpoint (`ShipmentWebhook`) for real-time shipment updates, complete with `Integration_Log__c` error logging and a Custom Setting kill switch (`Integration_Settings__c`).
* **Agentforce Support Agent (`ShipDesk Assistant`):** Configured topics, Flow actions, and customer identity verification (Order Number + Email) to handle order-status inquiries and log delay/return cases 24/7, validated via **Agentforce Testing Center**.
* **DevOps & Operations:** Managed source control in Git, deployed to a UAT org via Salesforce CLI (`sf`), and documented operational incident response in a SEV-1 runbook (`docs/runbook.md`). *(In progress: CI/CD pipeline with Copado and GitHub for automated validation and deployment.)*

## Quick Deployment

```bash
git clone https://github.com
cd shipdesk-salesforce
sf org login web --alias shipdesk-uat
sf project deploy start --source-dir force-app --target-org shipdesk-uat --test-level RunLocalTests
```

## Documentation
* `docs/requirements.md` — Functional requirements and user stories
* `docs/runbook.md` — SEV-1 / SEV-2 troubleshooting and kill-switch procedures
