import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)    

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Delete Company:')

st.text_input("Id", key="Id")

if st.button("Delete Company"):
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.delete(
            f"http://api:4000/c/companies/{st.session_state.Id}",
            headers=headers,
            data=json.dumps({}).encode()
        )
        response.raise_for_status()
        st.success("Company deleted successfully.")
    except requests.exceptions.HTTPError as err:
        st.error(f"Error: {err}")
    

