-- Group 7 - INSERT Mock Data
-- SQLite version aligned with new schema / app.py

PRAGMA foreign_keys = ON;

-- =========================================================
-- 1. Lookup Tables
-- =========================================================

INSERT INTO status (status_id, status_name) VALUES
(1, 'Using'),
(2, 'Under_maintenance'),
(3, 'Available');

INSERT INTO purpose (purpose_id, purpose_name) VALUES
(1, 'Research'),
(2, 'Teaching'),
(3, 'Clinical Trial'),
(4, 'Quality Control'),
(5, 'Prototyping'),
(6, 'Calibration Service'),
(7, 'Material Testing'),
(8, 'Data Collection'),
(9, 'Training'),
(10, 'Public Demonstration');

INSERT INTO equipment_type (
    equipment_type_id,
    type_name,
    description,
    requires_preparation,
    requires_oversight,
    usage_frequency,
    capability_description
) VALUES
(1, 'Analytical & Spectroscopy Instruments', 'Instruments for chemical and structural analysis', 1, 1, 'Daily', 'Mass spectrometry, NMR, XRD, HPLC'),
(2, 'Imaging & Microscopy Equipment', 'High-resolution imaging and microscopy devices', 1, 1, 'Daily', 'SEM, TEM, confocal, fMRI scanning'),
(3, 'Biological & Medical Equipment', 'Equipment for biological and medical research', 1, 0, 'Weekly', 'Flow cytometry, sequencing, centrifugation, bioprinting'),
(4, 'Fabrication & Engineering Equipment', 'Micro/nano fabrication and precision engineering', 1, 1, 'Weekly', 'Lithography, etching, deposition, CNC machining'),
(5, 'Large-Scale Physics & Testing', 'Large-scale physics experiments and environmental testing', 1, 1, 'Monthly', 'Beamline, high-power laser, environmental testing, wind tunnel');

INSERT INTO facility_type (
    facility_type_id,
    type_name,
    requires_training,
    requires_certification,
    intended_use_duration,
    capability_description
) VALUES
(1, 'Chemistry Lab', 1, 1, 'short-term', 'Chemical analysis and synthesis'),
(2, 'Cleanroom', 1, 1, 'short-term', 'Micro/nano fabrication in controlled environment'),
(3, 'Imaging Center', 1, 0, 'short-term', 'Microscopy and imaging services'),
(4, 'Biomedical Lab', 1, 1, 'long-term', 'Biological and medical experiments'),
(5, 'Physics Test Facility', 1, 1, 'long-term', 'Large-scale physics experiments'),
(6, 'Data Center', 0, 0, 'long-term', 'High-performance computing and storage'),
(7, 'Workshop', 1, 0, 'short-term', 'Mechanical fabrication and prototyping'),
(8, 'Environmental Testing Lab', 1, 0, 'short-term', 'Climate and stress testing'),
(9, 'General Research Lab', 0, 0, 'long-term', 'Multi-purpose research space'),
(10, 'Training Facility', 0, 0, 'short-term', 'Equipment training and certification');

INSERT INTO institution (institution_id, name, type, email_domain) VALUES
(1, 'MIT', 'university', 'mit.edu'),
(2, 'Stanford University', 'university', 'stanford.edu'),
(3, 'Johns Hopkins Hospital', 'hospital', 'jhmi.edu'),
(4, 'Caltech', 'university', 'caltech.edu'),
(5, 'Mayo Clinic', 'hospital', 'mayo.edu'),
(6, 'ETH Zurich', 'university', 'ethz.ch'),
(7, 'National Institutes of Health', 'research_institute', 'nih.gov'),
(8, 'University of Tokyo', 'university', 'u-tokyo.ac.jp'),
(9, 'Max Planck Institute', 'research_institute', 'mpg.de'),
(10, 'Cambridge University', 'university', 'cam.ac.uk');

INSERT INTO occupation (occupation_id, occupation_type) VALUES
(1, 'technical_staff'),
(2, 'researcher');

INSERT INTO application_result (result_id, application_result) VALUES
(1, 'approved'),
(2, 'rejected'),
(3, 'pending');

INSERT INTO charge_category (charge_category_id, charge_category) VALUES
(1, 'equipment_charge'),
(2, 'staff_support'),
(3, 'material_cost');

INSERT INTO funding_source (
    funding_source_id,
    payer_name,
    source_type,
    source_name,
    start_date,
    end_date,
    total_budget,
    status
) VALUES
(1, 'NSF', 'government_grant', 'NSF Award #2024-001', '2024-01-01', '2026-12-31', 5000.00, 'active'),
(2, 'NIH', 'government_grant', 'NIH R01 Grant', '2024-06-01', '2027-05-31', 7500.00, 'active'),
(3, 'MIT Internal Fund', 'institutional', 'MIT Research Fund 2025', '2025-01-01', '2025-12-31', 2000.00, 'active'),
(4, 'European Research Council', 'government_grant', 'ERC Starting Grant', '2024-03-01', '2029-02-28', 15000.00, 'active'),
(5, 'Pfizer Inc.', 'industry', 'Pfizer Collaboration Fund', '2025-01-01', '2026-06-30', 3000.00, 'active'),
(6, 'Stanford Seed Fund', 'institutional', 'Stanford Provost Fund', '2025-03-01', '2025-12-31', 1000.00, 'active'),
(7, 'DOE', 'government_grant', 'DOE Office of Science', '2024-09-01', '2027-08-31', 6000.00, 'active'),
(8, 'Toyota Research', 'industry', 'Toyota Materials Research', '2025-02-01', '2026-01-31', 2500.00, 'active'),
(9, 'Wellcome Trust', 'charity', 'Wellcome Biomedical Grant', '2024-04-01', '2027-03-31', 4000.00, 'active'),
(10, 'Caltech Endowment', 'institutional', 'Caltech Faculty Fund', '2025-01-01', '2025-12-31', 1500.00, 'active');


-- =========================================================
-- 2. Person & Authentication
-- =========================================================

INSERT INTO person (
    person_id,
    institution_id,
    full_name,
    email,
    phone,
    status,
    occupation_id
) VALUES
(1, 1, 'Alice Chen', 'alice.chen@mit.edu', '617-555-0101', 'active', 1),
(2, 1, 'Bob Martinez', 'bob.martinez@mit.edu', '617-555-0102', 'active', 1),
(3, 2, 'Carol Zhang', 'carol.zhang@stanford.edu', '650-555-0201', 'active', 1),
(4, 3, 'David Kim', 'david.kim@jhmi.edu', '410-555-0301', 'active', 1),
(5, 4, 'Eva Rossi', 'eva.rossi@caltech.edu', '626-555-0401', 'active', 1),
(6, 1, 'Frank Liu', 'frank.liu@mit.edu', '617-555-0103', 'active', 2),
(7, 2, 'Grace Park', 'grace.park@stanford.edu', '650-555-0202', 'active', 2),
(8, 3, 'Henry Wang', 'henry.wang@jhmi.edu', '410-555-0302', 'active', 2),
(9, 4, 'Irene Tanaka', 'irene.tanaka@caltech.edu', '626-555-0402', 'active', 2),
(10, 5, 'James Brown', 'james.brown@mayo.edu', '507-555-0501', 'active', 2),
(11, 6, 'Karen Mueller', 'karen.mueller@ethz.ch', '044-555-0601', 'active', 2),
(12, 7, 'Leo Singh', 'leo.singh@nih.gov', '301-555-0701', 'active', 2),
(13, 8, 'Mika Sato', 'mika.sato@u-tokyo.ac.jp', '03-555-0801', 'active', 2),
(14, 9, 'Nina Fischer', 'nina.fischer@mpg.de', '089-555-0901', 'active', 2),
(15, 10, 'Oscar Patel', 'oscar.patel@cam.ac.uk', '01223-555001', 'active', 2);

INSERT INTO credential (
    credential_id,
    person_id,
    issuer_type,
    provider,
    external_subject_id,
    status,
    issued_at,
    expires_at
) VALUES
(1, 1, 'home_institution', 'MIT SSO', 'MIT-001-ACHEN', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(2, 2, 'home_institution', 'MIT SSO', 'MIT-002-BMART', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(3, 3, 'home_institution', 'Stanford SSO', 'SU-001-CZHAN', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(4, 4, 'home_institution', 'JHU SSO', 'JHU-001-DKIM', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(5, 5, 'home_institution', 'Caltech SSO', 'CT-001-EROSS', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(6, 6, 'consortium', 'InCommon Federation', 'IC-006-FLIU', 'active', '2025-01-01 00:00:00', '2026-12-31 23:59:59'),
(7, 7, 'consortium', 'InCommon Federation', 'IC-007-GPARK', 'active', '2025-01-01 00:00:00', '2026-12-31 23:59:59'),
(8, 8, 'home_institution', 'JHU SSO', 'JHU-002-HWANG', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(9, 9, 'home_institution', 'Caltech SSO', 'CT-002-ITANA', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(10, 10, 'consortium', 'InCommon Federation', 'IC-010-JBROW', 'active', '2025-01-01 00:00:00', '2026-12-31 23:59:59'),
(11, 11, 'consortium', 'eduGAIN', 'EG-011-KMUEL', 'active', '2025-02-01 00:00:00', '2027-01-31 23:59:59'),
(12, 12, 'home_institution', 'NIH SSO', 'NIH-001-LSING', 'active', '2024-09-01 00:00:00', '2026-08-31 23:59:59'),
(13, 13, 'consortium', 'eduGAIN', 'EG-013-MSATO', 'active', '2025-03-01 00:00:00', '2027-02-28 23:59:59'),
(14, 14, 'consortium', 'eduGAIN', 'EG-014-NFISC', 'active', '2025-03-01 00:00:00', '2027-02-28 23:59:59'),
(15, 15, 'consortium', 'eduGAIN', 'EG-015-OPATE', 'active', '2025-04-01 00:00:00', '2027-03-31 23:59:59');


-- =========================================================
-- 3. Facility, Equipment, Assignment, Maintenance
-- =========================================================

INSERT INTO facility (
    facility_id,
    name,
    facility_type_id,
    purpose_id,
    status_id,
    address
) VALUES
(1, 'Analytical Chemistry Lab A', 1, 1, 1, 'Building 18, Room 201, MIT'),
(2, 'Nanofabrication Cleanroom', 2, 1, 3, 'Building 39, Floor B1, MIT'),
(3, 'Electron Microscopy Center', 3, 1, 1, 'Clark Center, Room 105, Stanford'),
(4, 'Biomedical Research Lab', 4, 3, 1, 'Pathology Building, Room 312, JHU'),
(5, 'High-Energy Physics Lab', 5, 1, 3, 'Lauritsen Lab, Room 001, Caltech'),
(6, 'Genomics Data Center', 6, 8, 1, 'Koch Institute, Room 010, MIT'),
(7, 'Precision Workshop', 7, 5, 3, 'Building 35, Room 102, MIT'),
(8, 'Environmental Test Facility', 8, 7, 2, 'Engineering Quad, Room 050, Stanford'),
(9, 'General Biology Lab B', 9, 1, 1, 'Science Hall, Room 220, Mayo Clinic'),
(10, 'Equipment Training Room', 10, 9, 3, 'Building 1, Room 101, MIT'),
(11, 'Materials Science Lab', 1, 1, 1, 'Gates Building, Room 305, Caltech'),
(12, 'Medical Imaging Suite', 3, 3, 1, 'Radiology Wing, Room 150, JHU');

INSERT INTO equipment (
    equipment_id,
    name,
    equipment_type_id,
    status_id
) VALUES
(1, 'Mass Spectrometer (MS)', 1, 1),
(2, 'Nuclear Magnetic Resonance (NMR) Spectrometer', 1, 3),
(3, 'X-ray Diffractometer (XRD)', 1, 1),
(4, 'High-Performance Liquid Chromatography (HPLC)', 1, 1),
(5, 'Scanning Electron Microscope (SEM)', 2, 1),
(6, 'Transmission Electron Microscope (TEM)', 2, 2),
(7, 'Confocal Laser Scanning Microscope', 2, 3),
(8, 'Functional MRI (fMRI) Scanner', 2, 1),
(9, 'Flow Cytometer', 3, 1),
(10, 'Next-Generation Sequencer (NGS)', 3, 3),
(11, 'Ultracentrifuge', 3, 1),
(12, '3D Bioprinter', 3, 2),
(13, 'Electron Beam Lithography (EBL) System', 4, 1),
(14, 'Reactive Ion Etcher (RIE)', 4, 3),
(15, 'Sputtering Deposition System', 4, 1),
(16, 'CNC Milling Machine', 4, 1),
(17, 'Particle Beamline', 5, 3),
(18, 'High-Power Laser System', 5, 1),
(19, 'Environmental Test Chamber', 5, 2),
(20, 'Wind Tunnel', 5, 3);

-- Current equipment locations.
-- This replaces the old equipment.facilityId column.
INSERT INTO assignment (
    assignment_id,
    equipment_id,
    facility_id,
    start_date,
    end_date
) VALUES
(1, 1, 1, '2025-01-01', NULL),
(2, 2, 1, '2025-01-01', NULL),
(3, 3, 11, '2025-01-01', NULL),
(4, 4, 1, '2025-01-01', NULL),
(5, 5, 3, '2025-01-01', NULL),
(6, 6, 3, '2025-01-01', NULL),
(7, 7, 3, '2025-01-01', NULL),
(8, 8, 12, '2025-01-01', NULL),
(9, 9, 4, '2025-01-01', NULL),
(10, 10, 4, '2025-01-01', NULL),
(11, 11, 9, '2025-01-01', NULL),
(12, 12, 4, '2025-01-01', NULL),
(13, 13, 2, '2025-01-01', NULL),
(14, 14, 2, '2025-01-01', NULL),
(15, 15, 2, '2025-01-01', NULL),
(16, 16, 7, '2025-01-01', NULL),
(17, 17, 5, '2025-01-01', NULL),
(18, 18, 5, '2025-01-01', NULL),
(19, 19, 8, '2025-01-01', NULL),
(20, 20, 8, '2025-01-01', NULL);

-- Unified maintenance table.
-- Old equipment_maintenance and facility_maintenance are merged here.
INSERT INTO maintenance (
    activity_id,
    target_type,
    target_id,
    activity_type,
    start_time,
    end_time,
    is_scheduled,
    person_id
) VALUES
(1, 'equipment', 1, 'maintenance', '2025-01-10 08:00:00', '2025-01-10 12:00:00', 1, 1),
(2, 'equipment', 1, 'calibration', '2025-02-15 09:00:00', '2025-02-15 11:00:00', 1, 1),
(3, 'equipment', 1, 'cleaning', '2025-03-20 08:00:00', '2025-03-20 10:00:00', 0, 2),
(4, 'equipment', 5, 'maintenance', '2025-01-05 08:00:00', '2025-01-05 16:00:00', 1, 3),
(5, 'equipment', 5, 'calibration', '2025-02-10 09:00:00', '2025-02-10 15:00:00', 1, 3),
(6, 'equipment', 5, 'inspection', '2025-03-12 10:00:00', '2025-03-12 12:00:00', 0, 3),
(7, 'equipment', 5, 'maintenance', '2025-04-01 08:00:00', '2025-04-01 17:00:00', 0, 3),
(8, 'equipment', 6, 'maintenance', '2025-02-20 08:00:00', '2025-02-21 17:00:00', 1, 3),
(9, 'equipment', 12, 'maintenance', '2025-01-15 08:00:00', '2025-01-15 12:00:00', 0, 4),
(10, 'equipment', 12, 'calibration', '2025-03-01 09:00:00', '2025-03-01 11:00:00', 1, 4),
(11, 'equipment', 13, 'inspection', '2025-02-01 10:00:00', '2025-02-01 12:00:00', 1, 2),
(12, 'equipment', 19, 'maintenance', '2025-01-20 08:00:00', '2025-01-22 17:00:00', 0, 5),
(13, 'equipment', 19, 'calibration', '2025-03-05 09:00:00', '2025-03-05 16:00:00', 1, 5),
(14, 'equipment', 8, 'maintenance', '2025-02-25 08:00:00', '2025-02-26 17:00:00', 1, 4),
(15, 'equipment', 16, 'cleaning', '2025-03-15 08:00:00', '2025-03-15 10:00:00', 0, 2),

(16, 'facility', 1, 'cleaning', '2025-01-06 06:00:00', '2025-01-06 08:00:00', 1, 1),
(17, 'facility', 1, 'inspection', '2025-02-03 09:00:00', '2025-02-03 11:00:00', 1, 1),
(18, 'facility', 2, 'cleaning', '2025-01-13 06:00:00', '2025-01-13 10:00:00', 1, 2),
(19, 'facility', 2, 'maintenance', '2025-03-10 08:00:00', '2025-03-11 17:00:00', 1, 2),
(20, 'facility', 3, 'cleaning', '2025-01-20 06:00:00', '2025-01-20 08:00:00', 1, 3),
(21, 'facility', 4, 'inspection', '2025-02-17 09:00:00', '2025-02-17 12:00:00', 1, 4),
(22, 'facility', 5, 'maintenance', '2025-01-27 08:00:00', '2025-01-28 17:00:00', 0, 5),
(23, 'facility', 8, 'maintenance', '2025-02-10 08:00:00', '2025-02-12 17:00:00', 1, 5),
(24, 'facility', 9, 'cleaning', '2025-03-03 06:00:00', '2025-03-03 08:00:00', 1, 4),
(25, 'facility', 11, 'inspection', '2025-03-17 09:00:00', '2025-03-17 11:00:00', 1, 5),
(26, 'facility', 12, 'cleaning', '2025-02-24 06:00:00', '2025-02-24 08:00:00', 1, 4),
(27, 'facility', 6, 'inspection', '2025-03-24 10:00:00', '2025-03-24 12:00:00', 0, 1);


-- =========================================================
-- 4. Experiment, Application, Allocation
-- =========================================================

INSERT INTO experiment (
    experiment_id,
    title,
    description,
    status
) VALUES
(1, 'Protein Folding Dynamics Study', 'Investigating protein misfolding mechanisms using NMR and MS', 'active'),
(2, 'Nanowire Synthesis for Solar Cells', 'Fabricating ZnO nanowires via EBL and sputtering deposition', 'active'),
(3, 'Tumor Microenvironment Imaging', 'High-resolution SEM/TEM imaging of tumor tissue samples', 'active'),
(4, 'CRISPR Gene Editing Validation', 'NGS-based validation of CRISPR edits in human cell lines', 'active'),
(5, 'High-Temperature Superconductor Analysis', 'XRD structural analysis of novel superconductor materials', 'paused'),
(6, 'Neural Circuit Mapping', 'fMRI-based mapping of motor cortex neural pathways', 'active'),
(7, 'Drug Compound Screening', 'HPLC and flow cytometry screening of candidate compounds', 'cancelled'),
(8, 'Microfluidic Chip Fabrication', 'Cleanroom fabrication of PDMS microfluidic devices', 'active'),
(9, 'Wind Load Testing on Bridge Models', 'Wind tunnel aerodynamic testing of scale bridge models', 'active'),
(10, 'Bioprinted Tissue Viability Study', '3D bioprinting and viability assessment of liver tissue', 'active'),
(11, 'Catalyst Surface Characterization', 'SEM and XRD analysis of platinum catalyst surfaces', 'completed'),
(12, 'Environmental Stress Testing of Alloys', 'Thermal cycling and humidity testing of aerospace alloys', 'active'),
(13, 'Stem Cell Differentiation Protocol', 'iPSC-derived neuron differentiation under chemical induction', 'completed'),
(14, 'Polymer Degradation Kinetics', 'Time-lapse mass spectrometry of biodegradable polymer breakdown', 'completed'),
(15, 'Deep-Sea Pressure Simulation', 'Hydrostatic pressure effects on microbial metabolism', 'completed'),
(16, 'Antibiotic Resistance Gene Profiling', 'Metagenomic sequencing of hospital-acquired pathogen samples', 'paused'),
(17, 'Quantum Dot Photoluminescence Study', 'Size-dependent emission properties of CdSe quantum dots', 'paused'),
(18, 'Aerosol Particle Deposition Modeling', 'CFD simulation validated by laser diffraction measurements', 'cancelled'),
(19, 'Retinal Cell Regeneration Trial', 'RPE cell transplant outcomes in murine retinal degeneration model', 'cancelled');

INSERT INTO experiment_phase (
    experiment_id,
    phase_start_date,
    phase_end_date
) VALUES
(1, '2025-01-15', '2025-03-15'),
(1, '2025-03-16', '2025-06-15'),
(2, '2025-02-01', '2025-04-30'),
(2, '2025-05-01', '2025-07-31'),
(3, '2025-01-10', '2025-03-10'),
(4, '2025-03-01', '2025-05-31'),
(4, '2025-06-01', '2025-08-31'),
(5, '2025-02-15', '2025-04-15'),
(6, '2025-01-20', '2025-04-20'),
(7, '2025-03-01', '2025-05-31'),
(8, '2025-02-10', '2025-04-10'),
(9, '2025-04-01', '2025-06-30'),
(10, '2025-03-15', '2025-06-15'),
(11, '2025-01-05', '2025-03-05'),
(12, '2025-04-01', '2025-07-01'),
(13, '2024-06-01', '2024-08-31'),
(13, '2024-09-01', '2024-11-30'),
(13, '2024-12-01', '2025-01-31'),
(14, '2024-07-01', '2024-10-31'),
(14, '2024-11-01', '2025-02-28'),
(15, '2024-05-01', '2024-09-30'),
(15, '2024-10-01', '2025-01-15'),
(16, '2025-01-10', '2025-03-10'),
(16, '2025-03-11', NULL),
(17, '2025-02-01', '2025-04-30'),
(17, '2025-05-01', NULL),
(18, '2025-03-01', '2025-04-15'),
(19, '2025-02-20', '2025-04-20');

INSERT INTO researcher_allocation (
    allocate_id,
    experiment_id,
    person_id
) VALUES
(1, 1, 6),
(2, 1, 7),
(3, 2, 9),
(4, 3, 7),
(5, 4, 8),
(6, 5, 9),
(7, 6, 10),
(8, 7, 11),
(9, 8, 6),
(10, 9, 13),
(11, 10, 12),
(12, 11, 14),
(13, 13, 10),
(14, 14, 11),
(15, 15, 12),
(16, 16, 13),
(17, 17, 14),
(18, 18, 15),
(19, 19, 6);

INSERT INTO application (
    application_id,
    person_id,
    experiment_id,
    submit_time,
    application_type,
    required_start_date,
    required_end_date,
    safety_consideration,
    special_note,
    estimated_usage,
    estimated_outcome,
    equipment_id,
    facility_id,
    staff_id
) VALUES
(1, 6, 1, '2025-01-05 09:30:00', 'equipment', '2025-01-20', '2025-02-20', 'Chemical handling protocols required', NULL, '40 hours', 'Protein structure data', 1, 1, 1),
(2, 7, 3, '2025-01-12 14:00:00', 'equipment', '2025-01-25', '2025-02-15', 'Electron beam safety training', NULL, '20 hours', 'High-res tumor images', 5, 3, 3),
(3, 8, 4, '2025-01-20 10:15:00', 'equipment', '2025-02-01', '2025-03-31', 'Biosafety level 2 required', 'Urgent clinical trial deadline', '60 hours', 'Validated CRISPR edits', 10, 4, 4),
(4, 9, 2, '2025-01-28 11:00:00', 'equipment', '2025-02-10', '2025-03-10', 'Cleanroom gowning protocol', NULL, '30 hours', 'Nanowire array samples', 13, 2, 2),
(5, 10, 6, '2025-02-03 08:45:00', 'equipment', '2025-02-15', '2025-03-15', 'MRI safety screening for subjects', 'IRB approval attached', '25 hours', 'Neural pathway maps', 8, 12, 4),
(6, 11, 7, '2025-02-10 16:30:00', 'equipment', '2025-02-20', '2025-03-20', 'Chemical waste disposal plan', NULL, '35 hours', 'Drug screening results', 4, 1, 1),
(7, 6, 8, '2025-02-18 09:00:00', 'equipment', '2025-03-01', '2025-03-15', 'Cleanroom protocols', NULL, '15 hours', 'Microfluidic chip prototypes', 13, 2, 2),
(8, 12, 10, '2025-02-25 13:20:00', 'equipment', '2025-03-10', '2025-04-30', 'Bioprinting material safety', NULL, '50 hours', 'Viable liver tissue constructs', 12, 4, 4),
(9, 13, 9, '2025-07-03 10:00:00', 'equipment', '2025-08-01', '2025-10-31', 'Wind tunnel safety barriers', 'Scale model provided', '20 hours', 'Aerodynamic load data', 20, 8, 5),
(10, 14, 11, '2025-03-10 11:30:00', 'equipment', '2025-03-20', '2025-04-10', 'X-ray radiation shielding', NULL, '30 hours', 'Catalyst surface structure data', 5, 3, 3),
(11, 15, 5, '2025-03-17 15:00:00', 'equipment', '2025-03-25', '2025-04-25', 'Cryogenic material handling', NULL, '25 hours', 'Superconductor XRD patterns', 3, 11, 5),
(12, 7, 1, '2025-03-24 09:45:00', 'equipment', '2025-04-01', '2025-04-20', 'NMR magnet safety', NULL, '20 hours', 'Additional NMR spectra', 2, 1, 1),
(13, 9, 12, '2025-08-11 08:30:00', 'equipment', '2025-09-01', '2025-10-15', 'Thermal hazard awareness', NULL, '40 hours', 'Alloy fatigue data', 19, 8, 5),
(14, 8, 4, '2025-04-07 14:15:00', 'equipment', '2025-04-15', '2025-05-31', 'BSL-2 protocols', 'Phase 2 of CRISPR study', '45 hours', 'Extended gene edit validation', 9, 4, 4),
(15, 6, 1, '2025-07-14 10:00:00', 'equipment', '2025-08-01', '2025-09-01', 'Chemical handling', NULL, '30 hours', 'Final protein analysis', 1, 1, 1),
(16, 10, 13, '2024-05-20 10:00:00', 'equipment', '2024-06-01', '2024-08-31', 'Biosafety level 2 required', NULL, '60 hours', 'Differentiated neuron cultures', 9, 4, 4),
(17, 11, 14, '2024-06-15 14:00:00', 'equipment', '2024-07-01', '2024-10-31', 'Chemical handling protocols required', NULL, '80 hours', 'Polymer degradation rate curves', 1, 1, 1),
(18, 12, 15, '2024-04-20 09:00:00', 'equipment', '2024-05-01', '2024-09-30', 'Pressure vessel safety certification required', NULL, '100 hours', 'Microbial metabolism measurements', 19, 8, 5),
(19, 13, 16, '2024-12-20 11:00:00', 'equipment', '2025-01-10', '2025-03-10', 'BSL-2 containment required', NULL, '40 hours', 'Resistance gene profiles', 10, 4, 4),
(20, 14, 17, '2025-01-15 10:30:00', 'equipment', '2025-02-01', '2025-04-30', 'Laser safety training required', NULL, '30 hours', 'Quantum dot emission spectra', 7, 3, 3),
(21, 15, 18, '2025-02-10 13:00:00', 'equipment', '2025-03-01', '2025-04-15', 'Wind tunnel safety protocols required', NULL, '20 hours', 'Aerosol deposition coefficients', 20, 8, 5),
(22, 6, 19, '2025-02-01 09:00:00', 'equipment', '2025-02-20', '2025-04-20', 'IRB approval required for animal subjects', 'Murine model protocol attached', '40 hours', 'RPE cell transplant viability rate', 8, 12, 4);

INSERT INTO application_review (
    review_id,
    application_id,
    result_id,
    justification
) VALUES
(1, 1, 1, 'All safety requirements met, equipment available'),
(2, 2, 1, 'Training verified, schedule confirmed'),
(3, 3, 1, 'Urgent request approved with priority scheduling'),
(4, 4, 1, 'Cleanroom slot available, approved'),
(5, 5, 1, 'IRB approval verified, MRI time allocated'),
(6, 6, 2, 'HPLC fully booked for requested period'),
(7, 7, 1, 'Cleanroom slot available'),
(8, 8, 1, 'Bioprinter maintenance completed, approved'),
(9, 9, 3, 'Pending wind tunnel schedule confirmation'),
(10, 10, 1, 'SEM time allocated'),
(11, 11, 2, 'XRD under maintenance during requested dates'),
(12, 12, 1, 'NMR available, approved'),
(13, 13, 3, 'Pending environmental chamber repair status'),
(14, 14, 1, 'BSL-2 lab confirmed available'),
(15, 15, 3, 'Pending staff availability confirmation'),
(16, 16, 1, 'BSL-2 requirements confirmed, schedule available'),
(17, 17, 1, 'Mass spectrometer slot available, protocol approved'),
(18, 18, 1, 'Pressure safety certification verified, approved'),
(19, 19, 1, 'NGS slot confirmed, BSL-2 lab available'),
(20, 20, 3, 'Pending laser safety certification from applicant'),
(21, 21, 2, 'Experiment cancelled before start, application rejected'),
(22, 22, 2, 'IRB approval not received within deadline');

INSERT INTO actual_allocation (
    allocation_id,
    application_id,
    actual_start_date,
    actual_end_date
) VALUES
(1, 1, '2025-01-20', '2025-02-20'),
(2, 2, '2025-01-25', '2025-02-15'),
(3, 3, '2025-02-01', '2025-03-31'),
(4, 4, '2025-02-10', '2025-03-10'),
(5, 5, '2025-02-15', '2025-03-15'),
(6, 7, '2025-03-01', '2025-03-15'),
(7, 8, '2025-03-10', '2025-04-30'),
(8, 10, '2025-03-20', '2025-04-10'),
(9, 12, '2025-08-01', '2025-09-15'),
(10, 14, '2025-09-01', '2025-10-31'),
(11, 16, '2024-06-01', '2024-08-31'),
(12, 17, '2024-07-01', '2024-10-31'),
(13, 18, '2024-05-01', '2024-09-30'),
(14, 19, '2025-01-10', '2025-03-10');


-- =========================================================
-- 5. Scheduling / Usage
-- =========================================================

INSERT INTO usage_record (
    usage_id,
    allocation_id,
    facility_id,
    equipment_id,
    start_time,
    end_time,
    quantity,
    usage_status,
    credential_id
) VALUES
(1, 1, 1, 1, '2025-01-20 09:00:00', '2025-01-20 17:00:00', '8 hours', 'completed', 6),
(2, 1, 1, 1, '2025-01-22 09:00:00', '2025-01-22 13:00:00', '4 hours', 'completed', 6),
(3, 2, 3, 5, '2025-01-25 10:00:00', '2025-01-25 18:00:00', '8 hours', 'completed', 7),
(4, 3, 4, 10, '2025-02-03 08:00:00', '2025-02-03 20:00:00', '12 hours', 'completed', 8),
(5, 4, 2, 13, '2025-02-12 09:00:00', '2025-02-12 17:00:00', '8 hours', 'completed', 9),
(6, 5, 12, 8, '2025-02-17 08:00:00', '2025-02-17 12:00:00', '4 hours', 'completed', 10),
(7, 6, 2, 13, '2025-03-03 09:00:00', '2025-03-03 15:00:00', '6 hours', 'completed', 6),
(8, 7, 4, 12, '2025-03-12 10:00:00', '2025-03-12 16:00:00', '6 hours', 'completed', 12),
(9, 8, 3, 5, '2025-03-22 09:00:00', '2025-03-22 17:00:00', '8 hours', 'completed', 14),
(10, 9, 1, 2, '2025-08-05 09:00:00', '2025-08-05 15:00:00', '6 hours', 'completed', 7),
(11, 10, 4, 9, '2025-09-16 08:00:00', '2025-09-16 16:00:00', '8 hours', 'completed', 8),
(12, 1, 1, 1, '2025-02-10 09:00:00', '2025-02-10 17:00:00', '8 hours', 'completed', 6),
(13, 11, 4, 9, '2024-06-05 09:00:00', '2024-06-05 17:00:00', '8 hours', 'completed', 10),
(14, 11, 4, 9, '2024-07-12 09:00:00', '2024-07-12 15:00:00', '6 hours', 'completed', 10),
(15, 12, 1, 1, '2024-07-08 10:00:00', '2024-07-08 18:00:00', '8 hours', 'completed', 11),
(16, 12, 1, 1, '2024-09-20 09:00:00', '2024-09-20 17:00:00', '8 hours', 'completed', 11),
(17, 13, 8, 19, '2024-05-10 08:00:00', '2024-05-10 20:00:00', '12 hours', 'completed', 12),
(18, 13, 8, 19, '2024-07-22 08:00:00', '2024-07-22 20:00:00', '12 hours', 'completed', 12),
(19, 14, 4, 10, '2025-01-15 09:00:00', '2025-01-15 17:00:00', '8 hours', 'completed', 13);


-- =========================================================
-- 6. Billing & Payment
-- =========================================================

INSERT INTO charge (
    charge_id,
    usage_id,
    charge_category_id,
    amount,
    status,
    person_id
) VALUES
(1, 1, 1, 500.00, 'paid', 6),
(2, 2, 1, 250.00, 'paid', 6),
(3, 3, 1, 800.00, 'paid', 7),
(4, 4, 1, 1200.00, 'paid', 8),
(5, 5, 1, 600.00, 'paid', 9),
(6, 6, 1, 1500.00, 'unpaid', 10),
(7, 7, 1, 450.00, 'paid', 6),
(8, 8, 1, 900.00, 'unpaid', 12),
(9, 9, 1, 800.00, 'paid', 14),
(10, 10, 1, 400.00, 'paid', 7),
(11, 11, 1, 350.00, 'unpaid', 8),
(12, 1, 2, 200.00, 'paid', 6),
(13, 4, 3, 300.00, 'paid', 8),
(14, 6, 2, 500.00, 'unpaid', 10),
(15, 8, 3, 150.00, 'unpaid', 12),
(16, 13, 1, 720.00, 'paid', 10),
(17, 14, 1, 540.00, 'paid', 10),
(18, 15, 1, 640.00, 'paid', 11),
(19, 16, 1, 640.00, 'paid', 11),
(20, 17, 1, 960.00, 'paid', 12),
(21, 18, 1, 960.00, 'paid', 12),
(22, 19, 1, 560.00, 'unpaid', 13);

INSERT INTO charge_allocation (
    charge_allocation_id,
    funding_source_id,
    charge_id,
    allocation_amount
) VALUES
(1, 1, 1, 500.00),
(2, 1, 2, 250.00),
(3, 6, 3, 800.00),
(4, 2, 4, 1200.00),
(5, 10, 5, 600.00),
(6, 2, 6, 1500.00),
(7, 3, 7, 450.00),
(8, 9, 8, 900.00),
(9, 4, 9, 800.00),
(10, 6, 10, 400.00),
(11, 2, 11, 350.00),
(12, 1, 12, 200.00),
(13, 2, 13, 300.00),
(14, 2, 14, 500.00),
(15, 9, 15, 150.00),
(16, 2, 16, 720.00),
(17, 2, 17, 540.00),
(18, 4, 18, 640.00),
(19, 4, 19, 640.00),
(20, 7, 20, 960.00),
(21, 7, 21, 960.00),
(22, 9, 22, 560.00);

INSERT INTO adjustment (
    adjustment_id,
    charge_id,
    adjustment_type,
    amount,
    reason_code
) VALUES
(1, 1, 'credit', 50.00, 'EARLY_RETURN'),
(2, 4, 'surcharge', 120.00, 'OVERTIME_USE'),
(3, 6, 'credit', 200.00, 'EQUIPMENT_DOWNTIME'),
(4, 3, 'surcharge', 80.00, 'CONSUMABLE_EXCESS'),
(5, 5, 'credit', 60.00, 'BOOKING_ERROR'),
(6, 8, 'surcharge', 100.00, 'MATERIAL_SURCHARGE'),
(7, 9, 'credit', 100.00, 'EARLY_RETURN'),
(8, 11, 'surcharge', 35.00, 'OVERTIME_USE'),
(9, 12, 'credit', 20.00, 'DISCOUNT_APPLIED'),
(10, 14, 'surcharge', 75.00, 'CONSUMABLE_EXCESS');

INSERT INTO payment (
    payment_id,
    charge_id,
    funding_source_id,
    paid_at,
    method,
    paid_amount
) VALUES
(1, 1, 1, '2025-02-28 10:00:00', 'bank_transfer', 450.00),
(2, 2, 1, '2025-02-28 10:00:00', 'bank_transfer', 250.00),
(3, 3, 6, '2025-03-15 14:00:00', 'bank_transfer', 880.00),
(4, 4, 2, '2025-03-31 09:00:00', 'wire_transfer', 1320.00),
(5, 5, 10, '2025-04-10 11:00:00', 'bank_transfer', 540.00),
(6, 7, 3, '2025-04-15 10:00:00', 'bank_transfer', 450.00),
(7, 9, 4, '2025-04-20 16:00:00', 'wire_transfer', 700.00),
(8, 10, 6, '2025-09-25 09:00:00', 'bank_transfer', 400.00),
(9, 12, 1, '2025-03-15 10:00:00', 'bank_transfer', 180.00),
(10, 13, 2, '2025-10-30 14:00:00', 'wire_transfer', 300.00),
(11, 16, 2, '2024-10-15 10:00:00', 'bank_transfer', 720.00),
(12, 17, 2, '2024-10-15 10:00:00', 'bank_transfer', 540.00),
(13, 18, 4, '2024-12-01 14:00:00', 'wire_transfer', 640.00),
(14, 19, 4, '2025-04-30 09:00:00', 'bank_transfer', 640.00),
(15, 20, 7, '2024-12-10 11:00:00', 'bank_transfer', 960.00),
(16, 21, 7, '2025-01-20 11:00:00', 'bank_transfer', 960.00);
