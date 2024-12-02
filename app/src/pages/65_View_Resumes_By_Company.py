import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume

logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("Search for Resume by Company:")

with st.form('search_form'):
    col1, col2 = st.columns([4, 1])
    with col1:
        prompt = st.text_input("Enter company name")
    with col2:
        search = st.form_submit_button('Search')

if search:
    if prompt:
        resumes = requests.get(f'http://api:4000/r/resumes/company={prompt}').json()
        for resume in resumes:
            render_resume(resume)
