import logging
import streamlit as st
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')
SideBarLinks()

st.title(f"Welcome co-op advisor, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

#As a co-op advisor, I need to be able to view students’ resumes that have successfully
#  gotten interviews at specific companies so that I can understand what resume elements 
# are appealing to recruiters and guide my students accordingly.
if st.button('View Resumes By Company',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/65_View_Resumes_By_Company.py')

# As a co-op advisor, I need to be able to filter resumes by degree so that I can provide 
# tailored resume advice to students pursuing jobs in different fields.
if st.button('View Resumes By Degree',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/71_View_Resumes_By_Degree.py')

if st.button('View Resumes That Got Interviews',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/73_View_Resumes_By_Interview_At_Company.py')

# As a co-op advisor, I need to be able to compare resumes from students with varying levels 
# of experience so that I can recommend different resume strategies based on each student's 
# background and skill set.
if st.button('Search Resumes by Number of Experiences',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/74_View_Resumes_By_Experience.py')

# As a co-op advisor, I need a way to view only my students interviews,
# without seeing other students, after a certain date.
if st.button('View My Students\' Interviews',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/75_View_Interviews_By_Student.py')

# As a co-op advisor, I need to see a list of my students, so that I can keep track of who I
# am advising and be able to look at their resumes.
if st.button('View My Students\' Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/76_View_Resumes_By_Advisor.py')
