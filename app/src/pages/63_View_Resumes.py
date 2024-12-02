import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume


logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("Resumes:")
st.markdown("---")

resumes = requests.get('http://api:4000/r/resumes').json()
for resume in resumes:
    render_resume(resume)
