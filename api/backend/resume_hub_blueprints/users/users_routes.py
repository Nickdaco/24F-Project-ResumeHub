from flask import Blueprint

users = Blueprint('users', __name__)


# GET /users
@users.route('/users', methods=['GET'])
def get_users():
    # TODO: Implement
    return None


# POST /users
@users.route('/users', methods=['POST'])
def post_users():
    # TODO: Implement
    return None


# GET /users/{user_id}
@users.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    # TODO: Implement
    return None


# PUT /users/{user_id}
@users.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    # TODO: Implement
    return None


# DELETE /users/{user_id}
@users.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    # TODO: Implement
    return None
