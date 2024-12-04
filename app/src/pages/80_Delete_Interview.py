import logging

import requests
import streamlit as st
import pandas as pd
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Delete Interview Page')

st.write("Interviews")
interview_data = requests.get("http://api:4000/i/interviews")
student_data = requests.get("http://api:4000/r/resumes/all_students")
student_name_id = {student["id"]: student["Name"]
                   for student in student_data.json()}
interview_df = pd.DataFrame([{"Student Name": student_name_id[y["StudentId"].replace("-", "")],
                              "Interview Date": y["InterviewDate"]}
                             for y in interview_data.json()])
interview_selected = st.dataframe(
    interview_df,
    on_select='rerun',
    selection_mode='single-row'
)

if len(interview_selected.selection['rows']):
    interview_selected_row = interview_selected.selection['rows'][0]
    interviee_name = interview_df.iloc[interview_selected_row]["Student Name"]
    interview_date = interview_df.iloc[interview_selected_row]["Interview Date"]
    selected_interview_json = interview_data.json()[interview_selected_row]

    if st.button(f"Would you like to delete {interviee_name} at {interview_date}"):
        try:
            response = requests.delete(
                f"http://api:4000/i/interviews/{selected_interview_json['Id']}"
            )
            response.raise_for_status()
            st.rerun()
        except requests.exceptions.HTTPError as err:
            st.error(f"Error: {err}")
