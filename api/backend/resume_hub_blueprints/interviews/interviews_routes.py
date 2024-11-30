from flask import Blueprint

interviews = Blueprint('interviews', __name__)


# POST /interviews
@interviews.route('/interviews', methods=['POST'])
def post_interview():
    # TODO: Implement
    return None


# GET /interviews/{student_id}
@interviews.route('/interviews/<int:student_id>', methods=['GET'])
def get_interviews(student_id):
    # TODO: Implement
    return None


# PUT /interviews/{interview_id}
@interviews.route('/interviews/<int:interview_id>', methods=['PUT'])
def update_interview(interview_id):
    # TODO: Implement
    return None


# DELETE /interviews/{interview_id}
@interviews.route('/interviews/<int:interview_id>', methods=['DELETE'])
def delete_interview(interview_id):
    # TODO: Implement
    return None


# GET /skills
@interviews.route('/skills', methods=['GET'])
def get_skills():
    # TODO: Implement
    return None


# PUT /skills/{skill_id}
@interviews.route('/skills/<int:skill_id>', methods=['PUT'])
def update_skill(skill_id):
    # TODO: Implement
    return None
