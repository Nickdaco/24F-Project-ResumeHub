import uuid

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

users = Blueprint('users', __name__)


# GET /users
# Return a list of all users.
@users.route('/users', methods=['GET'])
def get_users():
    query = 'SELECT * FROM User'
    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    # Convert binary UUID to string for each row
    for row in theData:
        if 'UUID' in row:
            row['UUID'] = str(uuid.UUID(bytes=row['UUID']))

    response = make_response(jsonify(theData))
    response.status_code = 200
    return response


# POST /users
@users.route('/users', methods=['POST'])
def post_users():
    user_info = request.json
    current_app.logger.info(user_info)

    name = user_info['Name']
    phone_number = user_info['PhoneNumber']
    email = user_info['Email']
    status = user_info['Status']
    user_type = user_info['UserType']

    query = f'''
        INSERT INTO User (PhoneNumber, Name, Email, Status, UserType)
        VALUES ('{phone_number}', '{name}', '{email}', '{status}', '{user_type}')
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully added user")
    response.status_code = 200

    return response


# GET /users/{user_uuid}
@users.route('/users/<user_uuid>', methods=['GET'])
def get_user(user_uuid):
    query = f'SELECT * FROM User WHERE UUID = UUID_TO_BIN("{user_uuid}")'

    cursor = db.get_db().cursor()
    cursor.execute(query)
    theData = cursor.fetchall()

    for row in theData:
        if 'UUID' in row:
            row['UUID'] = str(uuid.UUID(bytes=row['UUID']))

    response = make_response(jsonify(theData))
    response.status_code = 200
    return response


# PUT /users/{user_uuid}
@users.route('/users/<user_uuid>', methods=['PUT'])
def update_user(user_uuid):
    user_info = request.json
    current_app.logger.info(user_info)

    name = user_info['Name']
    phone_number = user_info['PhoneNumber']
    email = user_info['Email']
    status = user_info['Status']
    user_type = user_info['UserType']

    query = f'''
        UPDATE User
        SET
            PhoneNumber = '{phone_number}',
            Name = '{name}',
            Email = '{email}',
            Status = '{status}',
            UserType = {user_type}
        WHERE
            UUID = UUID_TO_BIN('{user_uuid}');
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully updated user")
    response.status_code = 200

    return response


# DELETE /users/{user_uuid}
@users.route('/users/<user_uuid>', methods=['DELETE'])
def delete_user(user_uuid):
    query = f'''
        DELETE FROM User
        WHERE UUID = UUID_TO_BIN('{user_uuid}');
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    response = make_response("Successfully deleted user")
    response.status_code = 200

    return response



