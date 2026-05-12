import sqlite3
from flask import Flask, jsonify, request, render_template, abort, g
from db import query, query_one, execute, get_db, DB_PATH
from datetime import date

app = Flask(__name__)


@app.teardown_appcontext
def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


# ─── Pages ────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    return render_template("index.html")


# ─── Resources: Equipment ──────────────────────────────────────────────────────

@app.route("/api/equipment")
def list_equipment():
    status_filter = request.args.get("status")
    type_filter = request.args.get("type_id")
    sql = """
        SELECT e.equipment_id, e.name, et.type_name, s.status_name,
               f.name AS facility_name, f.facility_id
        FROM equipment e
        JOIN equipment_type et ON e.equipment_type_id = et.equipment_type_id
        JOIN status s ON e.status_id = s.status_id
        LEFT JOIN assignment a ON e.equipment_id = a.equipment_id AND a.end_date IS NULL
        LEFT JOIN facility f ON a.facility_id = f.facility_id
        WHERE 1=1
    """
    params = []
    if status_filter:
        sql += " AND s.status_name = ?"
        params.append(status_filter)
    if type_filter:
        sql += " AND e.equipment_type_id = ?"
        params.append(type_filter)
    sql += " ORDER BY e.equipment_id"
    return jsonify(query(sql, params))


@app.route("/api/equipment/types")
def equipment_types():
    return jsonify(query("SELECT equipment_type_id, type_name FROM equipment_type ORDER BY type_name"))


@app.route("/api/equipment/<int:eid>")
def get_equipment(eid):
    item = query_one("""
        SELECT e.equipment_id, e.name, et.type_name, et.description,
               et.requires_preparation, et.requires_oversight,
               s.status_name,
               f.name AS facility_name, f.facility_id,
               a.start_date AS assigned_since
        FROM equipment e
        JOIN equipment_type et ON e.equipment_type_id = et.equipment_type_id
        JOIN status s ON e.status_id = s.status_id
        LEFT JOIN assignment a ON e.equipment_id = a.equipment_id AND a.end_date IS NULL
        LEFT JOIN facility f ON a.facility_id = f.facility_id
        WHERE e.equipment_id = ?
    """, (eid,))
    if not item:
        abort(404)
    item["usage"] = query("""
        SELECT ur.usage_id, ur.start_time, ur.end_time, ur.quantity, ur.usage_status,
               p.full_name AS user_name
        FROM usage_record ur
        JOIN actual_allocation aa ON ur.allocation_id = aa.allocation_id
        JOIN application ap ON aa.application_id = ap.application_id
        JOIN person p ON ap.person_id = p.person_id
        WHERE ur.equipment_id = ?
        ORDER BY ur.start_time DESC LIMIT 10
    """, (eid,))
    item["maintenance"] = query("""
        SELECT m.activity_id, m.activity_type, m.start_time, m.end_time,
               m.is_scheduled, p.full_name AS technician
        FROM maintenance m
        JOIN person p ON m.person_id = p.person_id
        WHERE m.target_id = ? AND m.target_type = 'equipment'
        ORDER BY m.start_time DESC LIMIT 10
    """, (eid,))
    return jsonify(item)


@app.route("/api/equipment/<int:eid>/reallocate", methods=["POST"])
def reallocate_equipment(eid):
    data = request.get_json()
    new_facility_id = data.get("facility_id")
    if not new_facility_id:
        return jsonify({"error": "facility_id required"}), 400
    today = date.today().isoformat()
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        conn.execute("UPDATE assignment SET end_date = ? WHERE equipment_id = ? AND end_date IS NULL",
                     (today, eid))
        conn.execute("INSERT INTO assignment (equipment_id, facility_id, start_date) VALUES (?, ?, ?)",
                     (eid, new_facility_id, today))
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
    return jsonify({"ok": True})


# ─── Resources: Facility ───────────────────────────────────────────────────────

@app.route("/api/facilities")
def list_facilities():
    return jsonify(query("""
        SELECT f.facility_id, f.name, ft.type_name, p.purpose_name,
               s.status_name, f.address
        FROM facility f
        JOIN facility_type ft ON f.facility_type_id = ft.facility_type_id
        JOIN purpose p ON f.purpose_id = p.purpose_id
        JOIN status s ON f.status_id = s.status_id
        ORDER BY f.facility_id
    """))


@app.route("/api/facilities/<int:fid>")
def get_facility(fid):
    item = query_one("""
        SELECT f.facility_id, f.name, ft.type_name, ft.capability_description,
               ft.requires_training, ft.requires_certification,
               p.purpose_name, s.status_name, f.address
        FROM facility f
        JOIN facility_type ft ON f.facility_type_id = ft.facility_type_id
        JOIN purpose p ON f.purpose_id = p.purpose_id
        JOIN status s ON f.status_id = s.status_id
        WHERE f.facility_id = ?
    """, (fid,))
    if not item:
        abort(404)
    item["equipment"] = query("""
        SELECT e.equipment_id, e.name, et.type_name, s.status_name
        FROM assignment a
        JOIN equipment e ON a.equipment_id = e.equipment_id
        JOIN equipment_type et ON e.equipment_type_id = et.equipment_type_id
        JOIN status s ON e.status_id = s.status_id
        WHERE a.facility_id = ? AND a.end_date IS NULL
        ORDER BY e.name
    """, (fid,))
    item["summary"] = query_one("""
        SELECT
            (SELECT COUNT(*)
             FROM assignment a
             WHERE a.facility_id = ? AND a.end_date IS NULL) AS equipment_count,
            (SELECT COUNT(*)
             FROM usage_record ur
             WHERE ur.facility_id = ?) AS usage_count,
            (SELECT ROUND(COALESCE(SUM(
                CASE WHEN ur.start_time IS NOT NULL AND ur.end_time IS NOT NULL
                THEN (julianday(ur.end_time) - julianday(ur.start_time)) * 24
                ELSE 0 END
             ), 0), 1)
             FROM usage_record ur
             WHERE ur.facility_id = ?) AS total_usage_hours
    """, (fid, fid, fid))
    item["usage"] = query("""
        SELECT ur.usage_id, ur.start_time, ur.end_time, ur.quantity, ur.usage_status,
               p.full_name AS user_name, eq.name AS equipment_name
        FROM usage_record ur
        JOIN actual_allocation aa ON ur.allocation_id = aa.allocation_id
        JOIN application ap ON aa.application_id = ap.application_id
        JOIN person p ON ap.person_id = p.person_id
        LEFT JOIN equipment eq ON ur.equipment_id = eq.equipment_id
        WHERE ur.facility_id = ?
        ORDER BY ur.start_time DESC LIMIT 10
    """, (fid,))
    item["maintenance"] = query("""
        SELECT m.activity_id, m.activity_type, m.start_time, m.end_time,
               m.is_scheduled, p.full_name AS technician
        FROM maintenance m
        JOIN person p ON m.person_id = p.person_id
        WHERE m.target_id = ? AND m.target_type = 'facility'
        ORDER BY m.start_time DESC LIMIT 10
    """, (fid,))
    return jsonify(item)


# ─── Experiments ──────────────────────────────────────────────────────────────

@app.route("/api/experiments")
def list_experiments():
    status_filter = request.args.get("status")
    sql = """
        SELECT e.experiment_id, e.title, e.status,
               COUNT(DISTINCT ep.phase_id) AS phase_count,
               COUNT(DISTINCT ra.person_id) AS team_size
        FROM experiment e
        LEFT JOIN experiment_phase ep ON e.experiment_id = ep.experiment_id
        LEFT JOIN researcher_allocation ra ON e.experiment_id = ra.experiment_id
        WHERE 1=1
    """
    params = []
    if status_filter:
        sql += " AND e.status = ?"
        params.append(status_filter)
    sql += " GROUP BY e.experiment_id ORDER BY e.experiment_id"
    return jsonify(query(sql, params))


@app.route("/api/experiments/<int:eid>")
def get_experiment(eid):
    item = query_one("SELECT * FROM experiment WHERE experiment_id = ?", (eid,))
    if not item:
        abort(404)
    item["phases"] = query("""
        SELECT phase_id, phase_start_date, phase_end_date
        FROM experiment_phase WHERE experiment_id = ?
        ORDER BY phase_id
    """, (eid,))
    item["team"] = query("""
        SELECT p.person_id, p.full_name, p.email, i.name AS institution,
               o.occupation_type
        FROM researcher_allocation ra
        JOIN person p ON ra.person_id = p.person_id
        JOIN institution i ON p.institution_id = i.institution_id
        JOIN occupation o ON p.occupation_id = o.occupation_id
        WHERE ra.experiment_id = ?
    """, (eid,))
    item["applications"] = query("""
        SELECT ap.application_id, ap.application_type, ap.submit_time,
               ap.required_start_date, ap.required_end_date,
               ar.justification,
               ares.application_result
        FROM application ap
        LEFT JOIN application_review ar ON ap.application_id = ar.application_id
        LEFT JOIN application_result ares ON ar.result_id = ares.result_id
        WHERE ap.experiment_id = ?
        ORDER BY ap.submit_time DESC
    """, (eid,))
    return jsonify(item)


@app.route("/api/experiments/<int:eid>/phases", methods=["POST"])
def add_experiment_phase(eid):
    if not query_one("SELECT experiment_id FROM experiment WHERE experiment_id = ?", (eid,)):
        abort(404)
    data = request.get_json() or {}
    start_date = data.get("phase_start_date")
    end_date = data.get("phase_end_date")
    if not start_date or not end_date:
        return jsonify({"error": "phase_start_date and phase_end_date required"}), 400
    if end_date < start_date:
        return jsonify({"error": "phase_end_date must be on or after phase_start_date"}), 400
    last_phase = query_one("""
        SELECT phase_end_date FROM experiment_phase
        WHERE experiment_id = ? AND phase_end_date IS NOT NULL
        ORDER BY phase_end_date DESC LIMIT 1
    """, (eid,))
    if last_phase and start_date < last_phase["phase_end_date"]:
        return jsonify({"error": f"Start date cannot be before the previous phase end date ({last_phase['phase_end_date']})"}), 400
    new_id = execute("""
        INSERT INTO experiment_phase (experiment_id, phase_start_date, phase_end_date)
        VALUES (?, ?, ?)
    """, (eid, start_date, end_date))
    return jsonify({"ok": True, "phase_id": new_id})


@app.route("/api/experiments/<int:eid>/phases/<int:pid>", methods=["PUT"])
def update_experiment_phase(eid, pid):
    data = request.get_json() or {}
    start_date = data.get("phase_start_date")
    end_date = data.get("phase_end_date")
    if not start_date or not end_date:
        return jsonify({"error": "phase_start_date and phase_end_date required"}), 400
    if end_date < start_date:
        return jsonify({"error": "phase_end_date must be on or after phase_start_date"}), 400
    existing = query_one("""
        SELECT phase_id FROM experiment_phase
        WHERE experiment_id = ? AND phase_id = ?
    """, (eid, pid))
    if not existing:
        abort(404)
    prev_phase = query_one("""
        SELECT phase_end_date FROM experiment_phase
        WHERE experiment_id = ? AND phase_id < ? AND phase_end_date IS NOT NULL
        ORDER BY phase_id DESC LIMIT 1
    """, (eid, pid))
    if prev_phase and start_date < prev_phase["phase_end_date"]:
        return jsonify({"error": f"Start date cannot be before previous phase end date ({prev_phase['phase_end_date']})"}), 400
    next_phase = query_one("""
        SELECT phase_start_date FROM experiment_phase
        WHERE experiment_id = ? AND phase_id > ? AND phase_start_date IS NOT NULL
        ORDER BY phase_id ASC LIMIT 1
    """, (eid, pid))
    if next_phase and end_date > next_phase["phase_start_date"]:
        return jsonify({"error": f"End date cannot be after next phase start date ({next_phase['phase_start_date']})"}), 400
    execute("""
        UPDATE experiment_phase
        SET phase_start_date = ?, phase_end_date = ?
        WHERE experiment_id = ? AND phase_id = ?
    """, (start_date, end_date, eid, pid))
    return jsonify({"ok": True})


@app.route("/api/experiments/<int:eid>/phases/<int:pid>", methods=["DELETE"])
def delete_experiment_phase(eid, pid):
    existing = query_one("""
        SELECT phase_id FROM experiment_phase
        WHERE experiment_id = ? AND phase_id = ?
    """, (eid, pid))
    if not existing:
        abort(404)
    execute("DELETE FROM experiment_phase WHERE experiment_id = ? AND phase_id = ?", (eid, pid))
    return jsonify({"ok": True})


# ─── Applications ─────────────────────────────────────────────────────────────

@app.route("/api/applications")
def list_applications():
    return jsonify(query("""
        SELECT ap.application_id, ap.application_type, ap.submit_time,
               ap.required_start_date, ap.required_end_date,
               p.full_name AS applicant,
               e.title AS experiment_title,
               ares.application_result AS status
        FROM application ap
        JOIN person p ON ap.person_id = p.person_id
        JOIN experiment e ON ap.experiment_id = e.experiment_id
        LEFT JOIN application_review ar ON ap.application_id = ar.application_id
        LEFT JOIN application_result ares ON ar.result_id = ares.result_id
        ORDER BY ap.submit_time DESC
    """))


@app.route("/api/applications/<int:aid>")
def get_application(aid):
    item = query_one("""
        SELECT ap.*,
               p.full_name AS applicant_name, p.email AS applicant_email,
               staff.full_name AS staff_name,
               e.title AS experiment_title,
               eq.name AS equipment_name,
               f.name AS facility_name
        FROM application ap
        JOIN person p ON ap.person_id = p.person_id
        JOIN person staff ON ap.staff_id = staff.person_id
        JOIN experiment e ON ap.experiment_id = e.experiment_id
        LEFT JOIN equipment eq ON ap.equipment_id = eq.equipment_id
        LEFT JOIN facility f ON ap.facility_id = f.facility_id
        WHERE ap.application_id = ?
    """, (aid,))
    if not item:
        abort(404)
    item["review"] = query_one("""
        SELECT ar.review_id, ar.justification, ares.application_result
        FROM application_review ar
        LEFT JOIN application_result ares ON ar.result_id = ares.result_id
        WHERE ar.application_id = ?
    """, (aid,))
    item["allocation"] = query_one("""
        SELECT allocation_id, actual_start_date, actual_end_date
        FROM actual_allocation WHERE application_id = ?
    """, (aid,))
    return jsonify(item)


@app.route("/api/applications", methods=["POST"])
def create_application():
    d = request.get_json()
    # Required fields
    for f in ["person_id", "experiment_id", "application_type", "staff_id"]:
        if not d.get(f):
            return jsonify({"error": f"{f} is required"}), 400
    for f in ["safety_consideration", "estimated_usage"]:
        if not (d.get(f) or "").strip():
            return jsonify({"error": f"{f} is required"}), 400

    app_type = d["application_type"]
    if app_type == "equipment" and not d.get("equipment_id"):
        return jsonify({"error": "Equipment must be selected"}), 400
    if app_type == "facility" and not d.get("facility_id"):
        return jsonify({"error": "Facility must be selected"}), 400

    start = d.get("required_start_date")
    end = d.get("required_end_date")
    if not start:
        return jsonify({"error": "Start date is required"}), 400
    if not end:
        return jsonify({"error": "End date is required"}), 400
    if end < start:
        return jsonify({"error": "End date must be on or after start date"}), 400

    new_id = execute("""
        INSERT INTO application
          (person_id, experiment_id, submit_time, application_type,
           required_start_date, required_end_date,
           safety_consideration, special_note, estimated_usage,
           estimated_outcome, equipment_id, facility_id, staff_id)
        VALUES (?,?,datetime('now'),?,?,?,?,?,?,?,?,?,?)
    """, (d["person_id"], d["experiment_id"], app_type,
          start, end,
          d.get("safety_consideration"), d.get("special_note"),
          d.get("estimated_usage"), d.get("estimated_outcome"),
          d.get("equipment_id"), d.get("facility_id"), d["staff_id"]))
    return jsonify({"application_id": new_id}), 201


# Support data for application form
@app.route("/api/form-data")
def form_data():
    return jsonify({
        "persons": query("""
            SELECT p.person_id, p.full_name FROM person p
            JOIN occupation o ON p.occupation_id = o.occupation_id
            WHERE o.occupation_type = 'researcher'
            ORDER BY p.full_name
        """),
        "experiments": query("SELECT experiment_id, title FROM experiment ORDER BY title"),
        "equipment": query("SELECT equipment_id, name FROM equipment ORDER BY name"),
        "facilities": query("SELECT facility_id, name FROM facility ORDER BY name"),
        "staff": query("""
            SELECT p.person_id, p.full_name FROM person p
            JOIN occupation o ON p.occupation_id = o.occupation_id
            WHERE o.occupation_type = 'technical_staff'
            ORDER BY p.full_name
        """),
    })


# ─── Scheduling ───────────────────────────────────────────────────────────────

@app.route("/api/scheduling/allocations")
def scheduling_allocations():
    return jsonify(query("""
        SELECT aa.allocation_id, aa.actual_start_date, aa.actual_end_date,
               e.title AS experiment_title, e.experiment_id,
               eq.name AS equipment_name,
               f.name AS facility_name,
               p.full_name AS applicant
        FROM actual_allocation aa
        JOIN application ap ON aa.application_id = ap.application_id
        JOIN experiment e ON ap.experiment_id = e.experiment_id
        LEFT JOIN equipment eq ON ap.equipment_id = eq.equipment_id
        LEFT JOIN facility f ON ap.facility_id = f.facility_id
        JOIN person p ON ap.person_id = p.person_id
        ORDER BY aa.actual_start_date
    """))


@app.route("/api/scheduling/usage")
def scheduling_usage():
    return jsonify(query("""
        SELECT ur.usage_id, ur.start_time, ur.end_time, ur.quantity, ur.usage_status,
               eq.name AS equipment_name,
               f.name AS facility_name,
               p.full_name AS user_name,
               cr.issuer_type, cr.provider AS credential_provider,
               e.title AS experiment_title
        FROM usage_record ur
        JOIN actual_allocation aa ON ur.allocation_id = aa.allocation_id
        JOIN application ap ON aa.application_id = ap.application_id
        JOIN experiment e ON ap.experiment_id = e.experiment_id
        LEFT JOIN equipment eq ON ur.equipment_id = eq.equipment_id
        LEFT JOIN facility f ON ur.facility_id = f.facility_id
        JOIN person p ON ap.person_id = p.person_id
        JOIN credential cr ON ur.credential_id = cr.credential_id
        ORDER BY ur.start_time DESC
    """))


# ─── Billing ──────────────────────────────────────────────────────────────────

@app.route("/api/billing/charges")
def list_charges():
    status_filter = request.args.get("status")
    category_filter = request.args.get("category")
    sql = """
        SELECT c.charge_id, c.amount, c.status,
               cc.charge_category,
               p.full_name AS person_name,
               ur.start_time AS usage_time,
               eq.name AS equipment_name
        FROM charge c
        JOIN charge_category cc ON c.charge_category_id = cc.charge_category_id
        JOIN person p ON c.person_id = p.person_id
        JOIN usage_record ur ON c.usage_id = ur.usage_id
        LEFT JOIN equipment eq ON ur.equipment_id = eq.equipment_id
        WHERE 1=1
    """
    params = []
    if status_filter:
        sql += " AND c.status = ?"
        params.append(status_filter)
    if category_filter:
        sql += " AND cc.charge_category = ?"
        params.append(category_filter)
    sql += " ORDER BY c.charge_id DESC"
    return jsonify(query(sql, params))


@app.route("/api/billing/filter-options")
def billing_filter_options():
    return jsonify({
        "statuses": query("SELECT DISTINCT status FROM charge ORDER BY status"),
        "categories": query("SELECT charge_category FROM charge_category ORDER BY charge_category"),
    })


@app.route("/api/billing/charges/<int:cid>")
def get_charge(cid):
    item = query_one("""
        SELECT c.charge_id, c.amount, c.status,
               cc.charge_category,
               p.full_name AS person_name,
               ur.start_time, ur.end_time, ur.quantity,
               eq.name AS equipment_name,
               f.name AS facility_name
        FROM charge c
        JOIN charge_category cc ON c.charge_category_id = cc.charge_category_id
        JOIN person p ON c.person_id = p.person_id
        JOIN usage_record ur ON c.usage_id = ur.usage_id
        LEFT JOIN equipment eq ON ur.equipment_id = eq.equipment_id
        LEFT JOIN facility f ON ur.facility_id = f.facility_id
        WHERE c.charge_id = ?
    """, (cid,))
    if not item:
        abort(404)
    item["adjustments"] = query("""
        SELECT adjustment_id, adjustment_type, amount, reason_code
        FROM adjustment WHERE charge_id = ?
    """, (cid,))
    item["allocations"] = query("""
        SELECT ca.allocation_amount, fs.payer_name, fs.source_type, fs.source_name
        FROM charge_allocation ca
        JOIN funding_source fs ON ca.funding_source_id = fs.funding_source_id
        WHERE ca.charge_id = ?
    """, (cid,))
    item["payments"] = query("""
        SELECT py.payment_id, py.paid_at, py.method, py.paid_amount,
               fs.payer_name
        FROM payment py
        JOIN funding_source fs ON py.funding_source_id = fs.funding_source_id
        WHERE py.charge_id = ?
    """, (cid,))
    return jsonify(item)


@app.route("/api/billing/charges/<int:cid>/pay", methods=["POST"])
def make_charge_payment(cid):
    charge = query_one("""
        SELECT charge_id, amount, status
        FROM charge
        WHERE charge_id = ?
    """, (cid,))
    if not charge:
        abort(404)
    if charge["status"] == "paid":
        return jsonify({"ok": True, "status": "paid"})

    allocations = query("""
        SELECT funding_source_id, allocation_amount
        FROM charge_allocation
        WHERE charge_id = ?
        ORDER BY charge_allocation_id
    """, (cid,))
    if not allocations:
        return jsonify({"error": "Cannot make payment without funding allocation"}), 400

    existing = query_one("""
        SELECT COALESCE(SUM(paid_amount), 0) AS paid_total
        FROM payment
        WHERE charge_id = ?
    """, (cid,))
    paid_total = float(existing["paid_total"] or 0)

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        if paid_total <= 0:
            for a in allocations:
                conn.execute("""
                    INSERT INTO payment (charge_id, funding_source_id, paid_at, method, paid_amount)
                    VALUES (?, ?, datetime('now'), ?, ?)
                """, (cid, a["funding_source_id"], "internal_transfer", a["allocation_amount"]))
        conn.execute("UPDATE charge SET status = 'paid' WHERE charge_id = ?", (cid,))
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    return jsonify({"ok": True, "status": "paid"})


@app.route("/api/billing/budget")
def billing_budget():
    return jsonify(query("""
        SELECT fs.funding_source_id, fs.payer_name, fs.source_type,
               fs.source_name, fs.total_budget, fs.status,
               fs.start_date, fs.end_date,
               COALESCE(SUM(ca.allocation_amount), 0) AS used_budget
        FROM funding_source fs
        LEFT JOIN charge_allocation ca ON fs.funding_source_id = ca.funding_source_id
        GROUP BY fs.funding_source_id
        ORDER BY fs.payer_name
    """))


# ─── Stats ────────────────────────────────────────────────────────────────────

@app.route("/api/stats/application-status")
def stats_application_status():
    return jsonify(query("""
        SELECT COALESCE(res.application_result, 'pending') AS status, COUNT(*) AS count
        FROM application ap
        LEFT JOIN application_review ar ON ap.application_id = ar.application_id
        LEFT JOIN application_result res ON ar.result_id = res.result_id
        GROUP BY COALESCE(res.application_result, 'pending')
    """))


@app.route("/api/stats/application-trend")
def stats_application_trend():
    return jsonify(query("""
        SELECT strftime('%Y-%m', submit_time) AS month, COUNT(*) AS count
        FROM application
        GROUP BY strftime('%Y-%m', submit_time)
        ORDER BY month
    """))


@app.route("/api/stats/equipment-status")
def stats_equipment_status():
    return jsonify(query("""
        SELECT s.status_name, COUNT(*) AS count
        FROM equipment e
        JOIN status s ON e.status_id = s.status_id
        GROUP BY s.status_name
    """))


@app.route("/api/stats/facility-status")
def stats_facility_status():
    return jsonify(query("""
        SELECT s.status_name, COUNT(*) AS count
        FROM facility f
        JOIN status s ON f.status_id = s.status_id
        GROUP BY s.status_name
    """))


@app.route("/api/stats/equipment-utilization")
def stats_equipment_utilization():
    return jsonify(query("""
        SELECT e.name,
               ROUND(SUM(
                   CASE WHEN ur.start_time IS NOT NULL AND ur.end_time IS NOT NULL
                   THEN (julianday(ur.end_time) - julianday(ur.start_time)) * 24
                   ELSE 0 END
               ), 1) AS total_hours
        FROM equipment e
        LEFT JOIN usage_record ur ON e.equipment_id = ur.equipment_id
        GROUP BY e.equipment_id
        HAVING total_hours > 0
        ORDER BY total_hours DESC
        LIMIT 8
    """))


if __name__ == "__main__":
    app.run(debug=True, port=5001)
