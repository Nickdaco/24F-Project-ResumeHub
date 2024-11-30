from flask import Blueprint

companies = Blueprint('companies', __name__)


# GET /companies
@companies.route('/companies', methods=['GET'])
def get_companies():
    # TODO: Implement
    return None


# POST /companies
@companies.route('/companies', methods=['POST'])
def post_company():
    # TODO: Implement
    return None


# GET /companies/{id}
@companies.route('/companies/<int:company_id>', methods=['GET'])
def get_company(company_id):
    # TODO: Implement
    return None


# PUT /companies/{id}
@companies.route('/companies/<int:company_id>', methods=['PUT'])
def update_company(company_id):
    # TODO: Implement
    return None


# DELETE /companies/{id}
@companies.route('/companies/<int:company_id>', methods=['DELETE'])
def delete_company(company_id):
    # TODO: Implement
    return None
