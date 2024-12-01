import uuid

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

interviews = Blueprint('interviews', __name__)


@interviews.route('/interviews', methods=['GET'])
def get_all_interviews():
    query = 'SELECT * FROM Interview'
    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    for row in theData:
        if 'StudentId' in row:
            row['StudentId'] = str(uuid.UUID(bytes=row['StudentId']))

    response = make_response(jsonify(theData))
    response.status_code = 200
    return response


# POST /interviews
# Given a Student ID, and company ID, store in the database that this user got an interview at this company.
# Also pass in a Date in the format ('2024-12-01')
@interviews.route('/interviews', methods=['POST'])
def post_interview():
    req = request.json
    current_app.logger.info(req)

    student_uuid = req['StudentId']
    company_id = req['CompanyId']
    date = req['Date']

    query = f'''
        INSERT INTO Interview (CompanyId, StudentId, InterviewDate)
        VALUES (
            {company_id},
            UUID_TO_BIN('{student_uuid}'),
            '{date}'
        );
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully added interview")
    response.status_code = 200

    return response


# GET /interviews/{student_id}
@interviews.route('/interviews/<student_uuid>', methods=['GET'])
def get_interviews(student_uuid):
    query = f'SELECT * FROM Interview WHERE StudentId = UUID_TO_BIN("{student_uuid}")'
    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    # Convert binary UUID to string for each row
    for row in theData:
        if 'StudentId' in row:
            row['StudentId'] = str(uuid.UUID(bytes=row['StudentId']))

    response = make_response(jsonify(theData))
    response.status_code = 200
    return response


# PUT /interviews/{interview_id}
# Updates Interview's PassedInterview field to true.
@interviews.route('/interviews/<int:interview_id>', methods=['PUT'])
def update_interview(interview_id):
    query = f'UPDATE Interview SET PassedInterview = TRUE WHERE Id = {interview_id}'
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully updated interview")
    response.status_code = 200

    return response


# DELETE /interviews/{interview_id}
@interviews.route('/interviews/<int:interview_id>', methods=['DELETE'])
def delete_interview(interview_id):
    query = f'''
        DELETE FROM Interview
        WHERE Id = {interview_id};
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully deleted interview")
    response.status_code = 200

    return response


# GET /skills
@interviews.route('/skills', methods=['GET'])
def get_skills():
    query = 'SELECT * FROM Skill'
    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()
    response = make_response(jsonify(theData))
    response.status_code = 200
    return response


# PUT /skills/{skill_id}
@interviews.route('/skills/<int:skill_id>', methods=['PUT'])
def update_skill(skill_id):
    user_info = request.json
    current_app.logger.info(user_info)

    name = user_info['Name']
    proficiency = user_info['Proficiency']

    query = f'''
            UPDATE Skill
            SET
                Name = '{name}',
                Proficiency = '{proficiency}'
            WHERE
                Id = '{skill_id}';
        '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully updated skill")
    response.status_code = 200

    return response

