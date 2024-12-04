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
logger = logging.getLogger(__name__)


# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# set the header of the page
st.header('Student Resumes')

# You can access the session state to make a more customized/personalized app experience
st.write(f"### Hi, {st.session_state['first_name']}.")


data = requests.get("http://api:4000/r/resumes/all_students")
df = pd.DataFrame(
    [{"Name": d["Name"]}
     for d in data.json()]
)

event = st.dataframe(
    df,
    on_select='rerun',
    selection_mode='single-row'
)


if len(event.selection['rows']):
    selected_row = event.selection['rows'][0]
    name = df.iloc[selected_row]['Name']
    name_id = [{x["Name"]: x["id"]} for x in data.json() if x["Name"] == name]
    resume_info = requests.get(
        f'http://api:4000/r/resumes/{name_id[0][name]}').json()

    st.session_state['resume_info'] = resume_info[0]
    st.page_link('pages/42_Resume.py', label=f'Goto {name} Page', icon='📝')
