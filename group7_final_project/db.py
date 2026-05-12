import sqlite3
import os
from flask import g

DB_PATH = os.path.join(os.path.dirname(__file__), "database", "group7_updated_v2.db")


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


def query(sql, params=()):
    rows = get_db().execute(sql, params).fetchall()
    return [dict(r) for r in rows]


def query_one(sql, params=()):
    row = get_db().execute(sql, params).fetchone()
    return dict(row) if row else None


def execute(sql, params=()):
    conn = get_db()
    cur = conn.execute(sql, params)
    conn.commit()
    return cur.lastrowid
