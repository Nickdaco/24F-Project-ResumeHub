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
    company_info= request.json
    current_app.logger.info(company_info)

    AcceptsInternational = company_info['AcceptsInternational']
    City = company_info['City']
    State = company_info['State']
    Country= company_info['Country']
    Name= company_info['Name']
    isActive=company_info['isActive']

    query = f'''
        INSERT INTO Company( AcceptsInternational,
                            City,
                            State,
                            Country,
                            Name,
                            isActive)
        VALUES('{int(AcceptsInternational)}',
                '{City}',
                '{State}',
                '{Country}',
                '{Name}',
                '{int(isActive)}')
    '''

    current_app.logger.info(query)

    cursor= db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    
    response=make_response("Successfully added company")
    response.status_code=200

    return response


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
