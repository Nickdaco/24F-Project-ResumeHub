import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Update your resume')


def generate_final_json():
    return {
        "Name": st.session_state.name,
        "Email": st.session_state.email,
        "City": st.session_state.city,
        "State": st.session_state.state,
        "Country": st.session_state.country,
    }


st.write("#### Contact Information")
col1, col2 = st.columns(2)
with col1:
    st.text_input("ResumeId", key="resume_id")
    st.text_input("Name", key="name")
    st.text_input("Email", key="email")
with col2:
    st.text_input("City", key="city")
    st.text_input('State (e.x. "MA")', key="state")
    st.text_input("Country", key="country")

if st.button("Update Resume"):
    final_json = generate_final_json()
    st.json(final_json)

    headers = {'Content-Type': 'application/json'}
    response = requests.put(
        f"http://api:4000/r/resumes/{st.session_state.resume_id}",
        headers=headers,
        data=json.dumps(final_json).encode(),
    )
    response.raise_for_status()
