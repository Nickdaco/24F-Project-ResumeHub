from flask import Blueprint

companies = Blueprint('companies', __name__)
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db
from backend.ml_models.model01 import predict

# GET /companies
@companies.route('/companies', methods=['GET'])
def get_companies():
    query = '''
    SELECT *
    FROM Company
    '''

    cursor=db.get_db().cursor()
    cursor.execute(query)
    theData=cursor.fetchall()

    response = make_response(jsonify(theData))
    response.status_case=200
    return response


# POST /companies
@companies.route('/companies', methods=['POST'])
def post_company():
    # TODO: Implement
    return None


# GET /companies/{company_id}
@companies.route('/companies/<int:company_id>', methods=['GET'])
def get_company(company_id):
    # TODO: Implement
    return None


# PUT /companies/{company_id}
@companies.route('/companies/<int:company_id>', methods=['PUT'])
def update_company(company_id):
    # TODO: Implement
    return None


# DELETE /companies/{company_id}
@companies.route('/companies/<int:company_id>', methods=['DELETE'])
def delete_company(company_id):
    # TODO: Implement
    return None
