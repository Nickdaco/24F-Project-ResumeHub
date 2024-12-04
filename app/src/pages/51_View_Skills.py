import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume


logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("Skills that students have on their resumes:")
st.markdown("---")

resumes = requests.get('http://api:4000/r/resumes').json()
skills = set()
for resume in resumes:
    resume_skills = resume.get('Skills', [])
    for skill in resume_skills:
        if skill['Name'] not in skills:
            skills.add(skill['Name'])
            st.write(skill['Name'])
