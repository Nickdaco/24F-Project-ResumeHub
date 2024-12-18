from backend.db_connection import db
from flask import current_app
from flask import make_response
from flask import jsonify
from flask import request
from flask import Blueprint

companies = Blueprint('companies', __name__)

# GET /companies
# Return the list of all countries with all attributes


@companies.route('/companies', methods=['GET'])
def get_companies():
    query = '''
    SELECT *
    FROM Company
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    response = make_response(jsonify(theData))
    response.status_case = 200
    return response


# POST /companies
# Update the companies table with a new entity
@companies.route('/companies', methods=['POST'])
def post_company():
    company_info = request.json
    current_app.logger.info(company_info)

    AcceptsInternational = company_info['AcceptsInternational']
    City = company_info['City']
    State = company_info['State']
    Country = company_info['Country']
    Name = company_info['Name']
    isActive = company_info['isActive']

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

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully added company")
    response.status_code = 200

    return response


# GET /companies/{company_id}
# Return the company whose id is supplied
@companies.route('/companies/<int:company_id>', methods=['GET'])
def get_company(company_id):
    query = '''
    SELECT *
    FROM Company
    WHERE Id= {0}'''.format(company_id)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    response = make_response(jsonify(theData))
    response.status_case = 200
    return response


# PUT /companies/{company_id}
# Update the attributes of en entity at the supplied id
@companies.route('/companies/<int:company_id>', methods=['PUT'])
def update_company(company_id):
    company_info = request.json
    current_app.logger.info(company_info)

    AcceptsInternational = company_info['AcceptsInternational']
    City = company_info['City']
    State = company_info['State']
    Country = company_info['Country']
    Name = company_info['Name']
    isActive = company_info['isActive']

    query = f'''
        UPDATE Company
        SET
            City = '{City}',
            State = '{State}',
            Country = '{Country}',
            Name = '{Name}',
            isActive = {isActive},
            AcceptsInternational = {AcceptsInternational}
        WHERE Id = {company_id}
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = jsonify("Company Updated")
    response.status_case = 200
    return response


# DELETE /companies/{company_id}
# Set a company to inactive (NOTE: Deleting the company will require deleting everything it is attached to)
@companies.route('/companies/<int:company_id>', methods=['DELETE'])
def delete_company(company_id):
    company_info = request.json
    current_app.logger.info(company_info)

    query = '''
        UPDATE Company
        SET IsActive= 0
        WHERE Id= {0}'''.format(company_id)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = jsonify("Company inactive")
    response.status_case = 200
    return response


@companies.route('/companies/recruiter/<recruiter_id>', methods=['GET'])
def get_company_by_recruiter_id(recruiter_id):
    query = '''
        SELECT C.* from Company C
        JOIN Recruiter R on '{0}' = BIN_TO_UUID(R.UserId)
        AND  R.CompanyId = C.Id;'''.format(recruiter_id)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    theData = cursor.fetchall()

    response = make_response(jsonify(theData))
    response.status_case = 200
    return response


@companies.route('/companies/student_at_recruiter_company/<recruiter_id>', methods=['GET'])
def get_student_at_recruiter_company(recruiter_id):
    query = '''
        SELECT 
            S.GithubLink as GithubLink,
            S.LinkedInLink as LinkedInLink,
            S.University,
            S.GraduationYear,
            S.CurrentCity as City,
            S.CurrentState as State,
            R.ResumeId as ResumeID,
            U.Name, 
            BIN_TO_UUID(S.UserId) as StudentID, 
            U.Email,
            R.Country
        FROM Student S
        JOIN Resumes R on S.UserId = R.StudentId
        JOIN ResumeCompany RC on R.ResumeId = RC.ResumeId
        JOIN Company C on C.Id = RC.CompanyId
        JOIN Recruiter R2 on C.Id = R2.CompanyId and
        BIN_TO_UUID(R2.UserId)='{0}'
        JOIN User U on S.UserId = UUID;
    '''.format(recruiter_id)
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    theData = cursor.fetchall()

    response = make_response(jsonify(theData))
    response.status_case = 200
    return response
