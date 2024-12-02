import logging
import streamlit as st
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')
SideBarLinks()

st.title(f"Welcome student, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

# User Stories for Persona 3:

# As a student, I need to be able to insert my resume information into the website,
# so that recruiters are able to see my resume to hire me.
if st.button('Upload a new resume', type='primary', use_container_width=True):
    st.switch_page('pages/61_Add_Resume.py')

# As a student, I need to be able to look at resumes other students have posted
# so that I can see what has successfully worked with other students.
if st.button('View All Resumes', type='primary', use_container_width=True):
    st.switch_page('pages/63_View_Resumes.py')

# As a student, I need to be able to update my resume so that I can keep my resume
# up to date with the most recent information.
if st.button('Update my resume', type='primary', use_container_width=True):
    st.switch_page('pages/62_Update_Resume.py')

# As a student, I need to be able to search for resumes that have experience in a co-op
# I am applying for so that I can potentially reach out for information on the interview process.

# As a student, I need to be able to add what companies I got interviews at so that
# other people can view my resume to improve theirs.

# As a student, I need to be able to see what skills a student has on their resume so
# that I can invest time into new skills for co-op applications


