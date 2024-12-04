import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Update Company Information:')

def generate_final_json():
    return {
        "Id": st.session_state.Id,
        "Name": st.session_state.name,
        "City": st.session_state.City,
        "State": st.session_state.State,
        "Country": st.session_state.Country,
        "isActive": st.session_state.isActive,
        "AcceptsInternational": st.session_state.AcceptsInternational,
    }

st.text_input("Company ID", key="Id")
st.text_input("Company Name", key="name")
st.text_input("City", key="City")
st.text_input("State", key="State")
st.text_input("Country", key="Country")
st.text_input("Is Active", key="isActive")
st.text_input("Accepts International", key="AcceptsInternational")

if st.button("Update Company Information"):
    final_json = generate_final_json()
    st.json(final_json)

    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.put(
            f"http://api:4000/c/companies/{st.session_state.Id}",
            headers=headers,
            data=json.dumps(final_json).encode(),
        )
        response.raise_for_status()
        st.success("Company information updated successfully!")
    except requests.exceptions.RequestException as e:
        st.error(f"An error occurred: {e}")

