import logging
import streamlit as st
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

if st.button('View Specific Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/41_Resume_List.py')

if st.button('View All Resumes',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/63_View_Resumes.py')
