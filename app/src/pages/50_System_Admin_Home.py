import logging
import streamlit as st
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')
SideBarLinks()

st.title(f"Welcome system administrator, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('View All Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/63_View_Resumes.py')
    
if st.button('View All Companies',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/66_View_Companies.py')

if st.button('View All Skills',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/51_View_Skills.py')

if st.button('Update Company Information',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/52_Update_Company_Info.py')
    
if st.button('Delete Resume',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/53_Delete_Resume.py')
    
if st.button('Delete Company',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/54_Delete_Company.py')
    
if st.button('Delete User',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/55_Delete_User.py')