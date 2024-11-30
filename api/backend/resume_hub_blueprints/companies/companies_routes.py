from flask import Blueprint
from flask import jsonify
from flask import make_response
from backend.db_connection import db

companies = Blueprint('companies', __name__)


