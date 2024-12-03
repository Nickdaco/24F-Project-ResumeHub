import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume

logger = logging.getLogger(__name__)


SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("View your students resumes")

def getId():
    all_users = requests.get(f'http://api:4000/u/users').json()
    advisor_id = "INVALID"
    for user in all_users:
        if user["Name"] == "Sam Miller":
            advisor_id = user["UUID"]
    return advisor_id

advisor_id= getId()

resumes = requests.get(f'http://api:4000/r/resumes/advisor_id/{advisor_id}').json()
for resume in resumes:
    render_resume(resume)