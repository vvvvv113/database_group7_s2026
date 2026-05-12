# Lab Management System
Topic: The Control Group Consortium

A laboratory resource management system that supports equipment and facility management, experiment tracking, application approval, scheduling calendars, and billing analysis.

---

## How to Start

**Requirements:** Python 3.x with Flask installed (`pip install flask`)

```bash
cd group7_final_project
python3 app.py
# Open http://localhost:5001 in your browser
```

> On macOS, port 5000 is often occupied by AirPlay, so this project uses **5001**.

---

## File Structure

```text
group7_final_project/
├── app.py                        # Flask backend, all API routes
├── db.py                         # SQLite connection utilities (query / execute)
│
├── database/
│   └── group7_updated_v2.db      # SQLite database (26 tables, including triggers)
│
├── docs/
│   ├── plan.md                   # Project plan and API documentation
│   ├── group7_schema.sql         # Database schema DDL
│   └── group7_insert.sql         # Mock data insert statements
│
├── static/
│   └── css/
│       └── style.css             # Global styles (Agilent blue-and-white theme)
│
└── templates/
    ├── index.html                # Main SPA page (navigation, sidebar, page templates, modals)
    ├── api.html                  # Fetch wrapper, status badges, and formatting utilities
    ├── usage_records.html        # Record the usage of the facilities and equipment
    ├── resources.html            # Equipment and facility module (lists, details, reallocation)
    ├── experiments.html          # Experiment module (lists, phase timeline, teams, linked applications)
    ├── applications.html         # Application module (lists, details, new application form, charts)
    ├── scheduling.html           # Scheduling module (calendar view, list view, usage records)
    └── billing.html              # Billing module (charge details, adjustments, budget progress)
```

---

## Feature Modules

### Resources

- **Equipment**: Equipment list with filtering by status/type; click to view details, including usage records and maintenance records; supports the Reallocate operation to move equipment to a new facility.
- **Facility**: Facility list with detail view, including type, purpose, status, and current equipment list; the detail page includes a facility summary/report, such as equipment count, number of usage records, total usage hours, most recent usage records, and maintenance records.
- **Charts**: Four status cards — Available / In Use / Maintenance / Total — plus a horizontal bar chart showing equipment usage hours.

### Experiments

- Experiment list with filtering by status: not started / in progress / completed.
- Click to view details: phase timeline, team members and their institutions, and linked applications with clickable navigation.
- **Phase management**: Supports adding phases, modifying phase start/end dates, and deleting phases. Both frontend and backend validation ensure that the end date cannot be earlier than the start date.

### Applications

- Application list showing type, status, applicant, time, and other information.
- Click to view details: basic information, review result and reason, and actual resource allocation records.
- **New application**: Supports either Equipment or Facility selection; includes required field validation for safety notes, estimated usage, and dates. The end date cannot be earlier than the start date, with validation on both the frontend and backend.
- **Charts**: Donut chart for application status distribution — Approved / Rejected / Pending — plus a monthly trend line chart.

### Scheduling

- **Calendar view** (default): Monthly grid calendar where allocations are displayed as continuous light-colored bars. The same experiment keeps the same color, making multi-day and cross-week scheduling clearer. Click a date to open the details for that day; month navigation is supported.
- **List view**: Allocation timeline distinguished by experiment color.
- Usage records table showing usage time, equipment, user, and credential issuer.

### Billing

- Charge list: Displays amount, status — paid / unpaid — category, and linked equipment; supports filtering by status and category.
- Charge details: Shows adjustment records — credit / surcharge — funding source allocation, and payment records.
- **Separate Budget view**: The Billing sidebar can switch between Charges and Budget. Each Funding Source shows a budget usage progress bar; above 70% turns orange, and above 90% turns red.
- Mock billing data has been checked and adjusted: all charge allocation totals match the corresponding charge totals, and budget usage rates are better suited for demonstration.

---

## Database Overview

| Domain | Main Tables |
|--------|-------------|
| People and institutions | institution, person, occupation, credential |
| Facilities and equipment | facility, equipment, assignment, maintenance |
| Experiments and applications | experiment, experiment_phase, application, application_review, actual_allocation |
| Billing and payment | charge, adjustment, charge_allocation, payment, funding_source, usage_record |

- 26 tables in total, with 3 triggers that ensure `actual_allocation` can only be linked to approved applications.
- Mock data: 20 pieces of equipment, 12 experiments, 19 applications including both equipment and facility applications, and 15 charges.

## ERD

Lucidchart: https://lucid.app/lucidchart/f204dc7d-e532-41e5-9a29-97c1902396ec/edit?page=0_0&invitationId=inv_75889f2b-f6d3-479b-9d9f-0519da84cb54
