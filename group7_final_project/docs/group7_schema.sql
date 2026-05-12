PRAGMA foreign_keys = ON;

-- Group 7 Schema
-- SQLite
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS adjustment;
DROP TABLE IF EXISTS charge_allocation;
DROP TABLE IF EXISTS charge;
DROP TABLE IF EXISTS funding_source;

DROP TABLE IF EXISTS usage_record;
DROP TABLE IF EXISTS actual_allocation;
DROP TABLE IF EXISTS application_review;
DROP TABLE IF EXISTS application;
DROP TABLE IF EXISTS researcher_allocation;
DROP TABLE IF EXISTS experiment_phase;
DROP TABLE IF EXISTS experiment;

DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS assignment;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS facility;

DROP TABLE IF EXISTS credential;
DROP TABLE IF EXISTS person;

DROP TABLE IF EXISTS charge_category;
DROP TABLE IF EXISTS application_result;
DROP TABLE IF EXISTS occupation;
DROP TABLE IF EXISTS institution;
DROP TABLE IF EXISTS facility_type;
DROP TABLE IF EXISTS equipment_type;
DROP TABLE IF EXISTS purpose;
DROP TABLE IF EXISTS status;
-- 1. Lookup Tables

CREATE TABLE status (
    status_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    status_name TEXT NOT NULL UNIQUE CHECK (
        status_name IN ('Using', 'Under_maintenance', 'Available')
    )
);

CREATE TABLE purpose (
    purpose_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    purpose_name TEXT NOT NULL UNIQUE
);

CREATE TABLE equipment_type (
    equipment_type_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name              TEXT NOT NULL UNIQUE,
    description            TEXT,
    requires_preparation   INTEGER NOT NULL DEFAULT 0 CHECK (requires_preparation IN (0, 1)),
    requires_oversight     INTEGER NOT NULL DEFAULT 0 CHECK (requires_oversight IN (0, 1)),
    usage_frequency        TEXT,
    capability_description TEXT
);

CREATE TABLE facility_type (
    facility_type_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name              TEXT NOT NULL UNIQUE,
    requires_training      INTEGER NOT NULL DEFAULT 0 CHECK (requires_training IN (0, 1)),
    requires_certification INTEGER NOT NULL DEFAULT 0 CHECK (requires_certification IN (0, 1)),
    intended_use_duration  TEXT NOT NULL CHECK (
        intended_use_duration IN ('short-term', 'long-term')
    ),
    capability_description TEXT
);

CREATE TABLE institution (
    institution_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name           TEXT NOT NULL,
    type           TEXT NOT NULL,
    email_domain   TEXT
);

CREATE TABLE occupation (
    occupation_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    occupation_type TEXT NOT NULL UNIQUE CHECK (
        occupation_type IN ('technical_staff', 'researcher')
    )
);

CREATE TABLE application_result (
    result_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    application_result TEXT NOT NULL UNIQUE
);

CREATE TABLE charge_category (
    charge_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    charge_category    TEXT NOT NULL UNIQUE CHECK (
        charge_category IN ('equipment_charge', 'staff_support', 'material_cost')
    )
);


-- 2. Person & Authentication

CREATE TABLE person (
    person_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    institution_id INTEGER NOT NULL,
    full_name      TEXT NOT NULL,
    email          TEXT NOT NULL UNIQUE,
    phone          TEXT,
    status         TEXT,
    occupation_id  INTEGER NOT NULL,

    FOREIGN KEY (institution_id) REFERENCES institution(institution_id),
    FOREIGN KEY (occupation_id)  REFERENCES occupation(occupation_id)
);

CREATE TABLE credential (
    credential_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id           INTEGER NOT NULL,
    issuer_type         TEXT NOT NULL CHECK (
        issuer_type IN ('home_institution', 'consortium')
    ),
    provider            TEXT,
    external_subject_id TEXT,
    status              TEXT,
    issued_at           TEXT,
    expires_at          TEXT,

    FOREIGN KEY (person_id) REFERENCES person(person_id)
);

-- 3. Facility, Equipment, Assignment, Maintenance

CREATE TABLE facility (
    facility_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name             TEXT NOT NULL,
    facility_type_id INTEGER NOT NULL,
    purpose_id       INTEGER NOT NULL,
    status_id        INTEGER NOT NULL,
    address          TEXT,

    FOREIGN KEY (facility_type_id) REFERENCES facility_type(facility_type_id),
    FOREIGN KEY (purpose_id)       REFERENCES purpose(purpose_id),
    FOREIGN KEY (status_id)        REFERENCES status(status_id)
);

CREATE TABLE equipment (
    equipment_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name              TEXT NOT NULL,
    equipment_type_id INTEGER NOT NULL,
    status_id         INTEGER NOT NULL,

    FOREIGN KEY (equipment_type_id) REFERENCES equipment_type(equipment_type_id),
    FOREIGN KEY (status_id)         REFERENCES status(status_id)
);

-- Equipment-to-facility assignment history.
-- The current facility is the row where end_date IS NULL.
CREATE TABLE assignment (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_id  INTEGER NOT NULL,
    facility_id   INTEGER NOT NULL,
    start_date    TEXT NOT NULL,
    end_date      TEXT,

    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    FOREIGN KEY (facility_id)  REFERENCES facility(facility_id)
);

-- Unified maintenance table used by app.py.
-- target_type = 'equipment' means target_id refers to equipment.equipment_id.
-- target_type = 'facility' means target_id refers to facility.facility_id.
CREATE TABLE maintenance (
    activity_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    target_type   TEXT NOT NULL CHECK (
        target_type IN ('equipment', 'facility')
    ),
    target_id     INTEGER NOT NULL,
    activity_type TEXT NOT NULL CHECK (
        activity_type IN ('maintenance', 'calibration', 'cleaning', 'inspection')
    ),
    start_time    TEXT NOT NULL,
    end_time      TEXT,
    is_scheduled  INTEGER NOT NULL DEFAULT 0 CHECK (is_scheduled IN (0, 1)),
    person_id     INTEGER NOT NULL,

    FOREIGN KEY (person_id) REFERENCES person(person_id)
);


-- 4. Experiment, Application, Allocation
CREATE TABLE experiment (
    experiment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title         TEXT NOT NULL,
    description   TEXT,
    status        TEXT NOT NULL DEFAULT 'active' CHECK (
        status IN ('active', 'completed', 'paused', 'cancelled')
    )
);

CREATE TABLE experiment_phase (
    phase_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_id    INTEGER NOT NULL,
    phase_start_date TEXT,
    phase_end_date   TEXT,

    FOREIGN KEY (experiment_id) REFERENCES experiment(experiment_id)
);

CREATE TABLE researcher_allocation (
    allocate_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_id INTEGER NOT NULL,
    person_id     INTEGER NOT NULL,

    FOREIGN KEY (experiment_id) REFERENCES experiment(experiment_id),
    FOREIGN KEY (person_id)     REFERENCES person(person_id)
);

CREATE TABLE application (
    application_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id            INTEGER NOT NULL,
    experiment_id        INTEGER NOT NULL,
    submit_time          TEXT NOT NULL,
    application_type     TEXT NOT NULL CHECK (
        application_type IN ('equipment', 'facility')
    ),
    required_start_date  TEXT NOT NULL,
    required_end_date    TEXT NOT NULL,
    safety_consideration TEXT NOT NULL,
    special_note         TEXT,
    estimated_usage      TEXT NOT NULL,
    estimated_outcome    TEXT,
    equipment_id         INTEGER,
    facility_id          INTEGER,
    staff_id             INTEGER NOT NULL,

    FOREIGN KEY (person_id)     REFERENCES person(person_id),
    FOREIGN KEY (experiment_id) REFERENCES experiment(experiment_id),
    FOREIGN KEY (equipment_id)  REFERENCES equipment(equipment_id),
    FOREIGN KEY (facility_id)   REFERENCES facility(facility_id),
    FOREIGN KEY (staff_id)      REFERENCES person(person_id),

    CHECK (
        (application_type = 'equipment' AND equipment_id IS NOT NULL)
        OR
        (application_type = 'facility' AND facility_id IS NOT NULL)
    )
);

CREATE TABLE application_review (
    review_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    application_id INTEGER NOT NULL,
    result_id      INTEGER,
    justification  TEXT,

    FOREIGN KEY (application_id) REFERENCES application(application_id),
    FOREIGN KEY (result_id)      REFERENCES application_result(result_id)
);

CREATE TABLE actual_allocation (
    allocation_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    application_id    INTEGER NOT NULL,
    actual_start_date TEXT,
    actual_end_date   TEXT,

    FOREIGN KEY (application_id) REFERENCES application(application_id)
);


-- 5. Scheduling / Usage

CREATE TABLE usage_record (
    usage_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    allocation_id INTEGER NOT NULL,
    facility_id   INTEGER NOT NULL,
    equipment_id  INTEGER,
    start_time    TEXT,
    end_time      TEXT,
    quantity      TEXT,
    usage_status  TEXT,
    credential_id INTEGER NOT NULL,

    FOREIGN KEY (allocation_id) REFERENCES actual_allocation(allocation_id),
    FOREIGN KEY (facility_id)   REFERENCES facility(facility_id),
    FOREIGN KEY (equipment_id)  REFERENCES equipment(equipment_id),
    FOREIGN KEY (credential_id) REFERENCES credential(credential_id)
);


-- 6. Billing & Payment

CREATE TABLE funding_source (
    funding_source_id INTEGER PRIMARY KEY AUTOINCREMENT,
    payer_name        TEXT NOT NULL,
    source_type       TEXT NOT NULL,
    source_name       TEXT,
    start_date        TEXT,
    end_date          TEXT,
    total_budget      NUMERIC,
    status            TEXT
);

CREATE TABLE charge (
    charge_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    usage_id           INTEGER NOT NULL,
    charge_category_id INTEGER NOT NULL,
    amount             NUMERIC NOT NULL,
    status             TEXT NOT NULL DEFAULT 'unpaid' CHECK (
        status IN ('unpaid', 'paid', 'disputed')
    ),
    person_id          INTEGER NOT NULL,

    FOREIGN KEY (usage_id)           REFERENCES usage_record(usage_id),
    FOREIGN KEY (charge_category_id) REFERENCES charge_category(charge_category_id),
    FOREIGN KEY (person_id)          REFERENCES person(person_id)
);

CREATE TABLE charge_allocation (
    charge_allocation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    funding_source_id    INTEGER NOT NULL,
    charge_id            INTEGER NOT NULL,
    allocation_amount    NUMERIC NOT NULL,

    FOREIGN KEY (funding_source_id) REFERENCES funding_source(funding_source_id),
    FOREIGN KEY (charge_id)         REFERENCES charge(charge_id)
);

CREATE TABLE adjustment (
    adjustment_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    charge_id       INTEGER NOT NULL,
    adjustment_type TEXT NOT NULL CHECK (
        adjustment_type IN ('credit', 'surcharge')
    ),
    amount          NUMERIC NOT NULL,
    reason_code     TEXT,

    FOREIGN KEY (charge_id) REFERENCES charge(charge_id)
);

CREATE TABLE payment (
    payment_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    charge_id         INTEGER NOT NULL,
    funding_source_id INTEGER NOT NULL,
    paid_at           TEXT,
    method            TEXT,
    paid_amount       NUMERIC NOT NULL,

    FOREIGN KEY (charge_id)         REFERENCES charge(charge_id),
    FOREIGN KEY (funding_source_id) REFERENCES funding_source(funding_source_id)
);


-- Indexes
CREATE INDEX idx_assignment_equipment   ON assignment(equipment_id);
CREATE INDEX idx_assignment_facility    ON assignment(facility_id);
CREATE INDEX idx_usage_record_facility  ON usage_record(facility_id);
CREATE INDEX idx_application_experiment ON application(experiment_id);
CREATE INDEX idx_charge_status          ON charge(status);
CREATE INDEX idx_experiment_status      ON experiment(status);
