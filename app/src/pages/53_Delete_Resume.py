import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)    

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Delete Resume:')


st.text_input("Resume ID", key="ResumeID")

if st.button("Delete Resume"):
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.delete(
            f"http://api:4000/r/resumes/{st.session_state.ResumeID}",
            headers=headers
        )
        response.raise_for_status()
        st.success("Resume deleted successfully.")
    except requests.exceptions.HTTPError as err:
        st.error(f"Error: {err}")
    

