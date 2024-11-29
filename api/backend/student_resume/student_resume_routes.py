from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db
from backend.ml_models.model01 import predict

# ------------------------------------------------------------
# Create a new Blueprint object, which is a collection of
# routes.
resumes = Blueprint('resumes', __name__)


@resumes.route('/all_students', methods=['GET'])
def get_all_students():
    query = '''
        select s.UserId as id, R.Name 
        from ResumeDB.Student as s 
        join ResumeDB.Resumes R on s.UserId = R.StudentId
    '''

    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of products
    cursor.execute(query)

    # fetch all the data from the cursor
    # The cursor will return the data as a
    # Python Dictionary
    theData = cursor.fetchall()

    # Create a HTTP Response object and add results of the query to it
    # after "jasonify"-ing it.
    response = make_response(jsonify(theData))
    # set the proper HTTP Status code of 200 (meaning all good)
    response.status_code = 200
    # send the response back to the client
    return response
