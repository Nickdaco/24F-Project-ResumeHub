import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Add interview information')


def generate_final_json():
    all_users = requests.get(f'http://api:4000/u/users').json()
    student_id = "INVALID"
    for user in all_users:
        if user["Name"] == "Kyle Mitchell":
            student_id = user["UUID"]

    return {
        "StudentId": student_id,
        "CompanyId": st.session_state.company_id,
        "Date": st.session_state.date.strftime('%Y-%m-%d'),
    }


st.write("#### Interview Information")
col1, col2 = st.columns(2)
with col1:
    st.text_input("CompanyId", key="company_id")
with col2:
    st.date_input("Date", key="date")

if st.button("Add Interview"):
    final_json = generate_final_json()
    st.json(final_json)

    headers = {'Content-Type': 'application/json'}
    response = requests.post(
        f"http://api:4000/i/interviews",
        headers=headers,
        data=json.dumps(final_json).encode(),
    )
    response.raise_for_status()
