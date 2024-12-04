import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume

logger = logging.getLogger(__name__)


SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("View Students With Experience at Your Company")

# The UUID changes each time the docker container starts, rather than implement a log in system to mitigate this
# (and also break the rules of the project) We elected to search for the UUID instead.


def getId():
    all_users = requests.get(f'http://api:4000/u/users').json()
    recruiter_id = "INVALID"
    for user in all_users:
        if user["Name"] == "Bob Brown":
            recruiter_id = user["UUID"]
    return recruiter_id


recruiter_id = getId()

students = requests.get(
    f'http://api:4000/c/companies/student_at_recruiter_company/{recruiter_id}').json()
for student in students:
    render_resume(student)
