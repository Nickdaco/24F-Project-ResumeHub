import logging
import requests
from datetime import datetime
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
        date = st.date_input("Enter Cutoff Date")
        date = datetime.strptime(date.ctime(), "%a %b %d %H:%M:%S %Y")
    with col2:
        search = st.form_submit_button('Search')

if search:
    if date:

        interviews = requests.get(f'http://api:4000/i/interviews').json()
        for interview in interviews:
            
            interviewDate= datetime.strptime(interview['InterviewDate'], "%a, %d %b %Y %H:%M:%S %Z")
            if(date<interviewDate):
                render_interview(interview)
