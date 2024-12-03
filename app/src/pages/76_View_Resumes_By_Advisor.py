import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume

logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("View your students resumes")

UUID=st.session_state['UUID']

resumes = requests.get(f'http://api:4000/r/resumes/advisor_id/{UUID}').json()
for resume in resumes:
    render_resume(resume)
