import json
from pathlib import Path
from modules.nav import SideBarLinks
import plotly.express as px
import numpy as np
import matplotlib.pyplot as plt
import world_bank_data as wb
from streamlit_extras.app_logo import add_logo
import streamlit as st
import pandas as pd
import logging
import requests
import datetime

logger = logging.getLogger(__name__)


# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# set the header of the page
st.header('Student Resumes')

# You can access the session state to make a more customized/personalized app experience
st.write(f"### Hi, {st.session_state['first_name']}.")


def getId():
    all_users = requests.get(f'http://api:4000/u/users').json()
    recruiter_id = "INVALID"
    for user in all_users:
        if user["Name"] == "Bob Brown":
            recruiter_id = user["UUID"]
    return recruiter_id


recruiter_id = getId()


col1, col2 = st.columns(2)
with col1:
    st.write("Students Looking for a Co-op/Internship")
    student_data = requests.get("http://api:4000/r/all_students")
    student_df = pd.DataFrame(
        [{"Name": d["Name"]}
         for d in student_data.json()]
    )

    student_selected = st.dataframe(
        student_df,
        on_select='rerun',
        selection_mode='single-row'
    )
with col2:
    st.write("Companies You Work For")
    companies_json = requests.get(
        f'http://api:4000/c/companies/recruiter/{recruiter_id}')
    company_df = pd.DataFrame(
        [{"Name": d["Name"]}
         for d in companies_json.json()]
    )

    company_selected = st.dataframe(
        company_df,
        on_select='rerun',
        selection_mode='single-row'
    )

if len(student_selected.selection['rows']) and len(company_selected.selection['rows']):

    student_selected_row = student_selected.selection['rows'][0]
    student_name = student_df.iloc[student_selected_row]['Name']
    student_id = [x["id"]
                  for x in student_data.json() if x["Name"] == student_name]

    company_selected_row = company_selected.selection['rows'][0]
    company_name = company_df.iloc[company_selected_row]['Name']
    companies_id = [x["Id"]
                    for x in companies_json.json() if x["Name"] == company_name]

    if st.button(f"Interview Student {student_name} at {company_name}"):
        date_json = json.dumps(datetime.datetime.now(),
                               indent=4, sort_keys=True, default=str)
        post_data = {'StudentId': student_id[0],
                     'CompanyId': companies_id[0],
                     'Date': date_json.replace('"', "")}
        headers = {'Content-Type': 'application/json'}
        try:
            response = requests.post(
                f"http://api:4000/i/interviews",
                headers=headers,
                data=json.dumps(post_data).encode(),
            )
            response.raise_for_status()
        except requests.exceptions.HTTPError as err:
            st.error(f"Error: {err}")
