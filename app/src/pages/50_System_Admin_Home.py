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

if st.button('View World Bank Data Visualization',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/01_World_Bank_Viz.py')

if st.button('View World Map Demo',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/02_Map_Demo.py')
