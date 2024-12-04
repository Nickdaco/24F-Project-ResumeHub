import logging
import requests
from datetime import datetime
from pages.resume_view_utils import render_resume
import streamlit as st
from modules.nav import SideBarLinks
from pages.interview_view_utils import render_interview
from pages.interview_view_utils import format_date

logger = logging.getLogger(__name__)


SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("Search for Interviews After a Date")

with st.form('search_form'):
    col1, col2 = st.columns([4, 1])
    with col1:
        prompt = st.text_input(
            "Student's User Id")
    with col2:
        search = st.form_submit_button('Search')
if search:
    if prompt:
        resumes = requests.get(
            f'http://api:4000/r/resumes/exclude_user_ids={prompt}').json()
        for resume in resumes:
            render_resume(resume)
