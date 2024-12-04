import logging
import streamlit as st
import requests
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently logged in user
# These are set up in modules/nav.py
SideBarLinks()

st.title(f"Welcome technical recruiter, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')


def getId():
    all_users = requests.get(f'http://api:4000/u/users').json()
    recruiter_id = "INVALID"
    for user in all_users:
        if user["Name"] == st.session_state['full_name']:
            recruiter_id = user["UUID"]
    return recruiter_id


st.session_state['recruiter_id'] = getId()

if st.button('View Resumes by Skills',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/82_Resume_By_Skills.py')

if st.button('Ignore Candidates',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/83_Ignore_Candidates.py')

if st.button('View All Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/63_View_Resumes.py')


if st.button('View All Companies',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/66_View_Companies.py')

if st.button('View My Company Info',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/77_Company_Info.py')

if st.button('View Students That Worked At Your Company',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/78_Student_At_Same_Company_As_Recruiter.py')

if st.button('Select Students to Interview',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/79_Select_Interview.py')

if st.button('Future Interviews',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/81_Future_Interviews.py')

if st.button('Delete Interview',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/80_Delete_Interview.py')

if st.button('Edit Company', type='primary', use_container_width=True):
    st.switch_page('pages/43_Recruiter_Company_Edit.py')
