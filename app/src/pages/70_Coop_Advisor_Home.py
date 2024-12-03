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

if st.button('View Resumes By Company',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/65_View_Resumes_By_Company.py')

if st.button('View Resumes By Degree',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/71_View_Resumes_By_Degree.py')

if st.button('View My Student\'s Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/76_View_Resumes_By_Advisor.py')
