import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Delete User:')

st.text_input("UUID", key="UUID")

if st.button("Delete User"):
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.delete(
            f"http://api:4000/u/users/{st.session_state.UUID}",
            headers=headers
            # data=json.dumps({}).encode()
        )
        response.raise_for_status()
        st.success("User deleted successfully.")
    except requests.exceptions.HTTPError as err:
        st.error(f"Error: {err}")
