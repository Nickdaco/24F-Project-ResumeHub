import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.interview_view_utils import render_interview

logger = logging.getLogger(__name__)



SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("Search for Resume by Education:")

with st.form('search_form'):
    col1, col2 = st.columns([4, 1])
    with col1:
        prompt = st.text_input("Enter Student Name")
    with col2:
        search = st.form_submit_button('Search')

if search:
    if prompt:
        interviews = requests.get(f'http://api:4000/i/interviews').json()
        for interview in interviews:
            render_interview(interview)
