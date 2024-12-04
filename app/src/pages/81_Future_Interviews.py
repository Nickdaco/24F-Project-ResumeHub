import logging

import requests
import streamlit as st
import pandas as pd
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Current Interview Page')

st.write("Interviews")
interview_data = requests.get("http://api:4000/i/interviews")
student_data = requests.get("http://api:4000/r/all_students")
student_name_id = {student["id"]: student["Name"]
                   for student in student_data.json()}
interview_df = pd.DataFrame([{"Student Name": student_name_id[y["StudentId"].replace("-", "")],
                              "Interview Date": y["InterviewDate"]}
                             for y in interview_data.json()])
interview_selected = st.dataframe(
    interview_df
)
