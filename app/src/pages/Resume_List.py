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
logger = logging.getLogger(__name__)

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()
# showSidebarNavigation = false

# set the header of the page
st.header('Student Resumes')

#
# You can access the session state to make a more customized/personalized app experience
st.write(f"### Hi, {st.session_state['first_name']}.")


# def student_resume(id):
#     if st.button('View Resumes',
#                  type='primary',
#                  use_container_width=True,
#                  key=id):
#         st.switch_page('pages/Resume_List.py')


# with st.echo(code_location='above'):
# col1, col2 = st.columns([5, 1])
# col1.write("This is column 1")
# col2.write("This is column 2")
df = pd.DataFrame(
    [
        {"Name": "John Doe"},
        {"Name": "Jane Doe"},
        {"Name": "Josh Doe"},
    ]
)

event = st.dataframe(
    df,
    on_select='rerun',
    selection_mode='single-row'
)


if len(event.selection['rows']):
    selected_row = event.selection['rows'][0]
    name = df.iloc[selected_row]['Name']

    st.session_state['resume_info'] = {'resume_name': name,
                                       'eduction_info': [{
                                           "name": "University College",
                                           "degree": "Study of Studies",
                                           "Field": "Eduction",
                                           "StartDate": "11/28/2024",
                                           "EndDate": "11/29/2024",
                                           "Description": "I Studied"}],
                                       'experience_info': [{
                                           "company_name": "Company",
                                           "position_title": "Manager",
                                           "city": "NYC",
                                           "state": "NY",
                                           "StartDate": "11/28/2024",
                                           "EndDate": "11/29/2024",
                                           "Description": "I Worked"
                                       }],
                                       'skills_info': [{
                                           "name": "Writing",
                                           "proficiency": "Experienced"
                                       }]
                                       }
    st.page_link('pages/resume.py', label=f'Goto {name} Page', icon='📝')

# with col1:
# st.dataframe(df, use_container_width=True, column_config={
#     "Resume Url": st.column_config.LinkColumn("Resume Url"),
# })

# with col2:
#     # size_of = df.size()
#     for i in range(6):
#         st.button("Click me", key=i)
# get the countries from the world bank data
# with st.echo(code_location='above'):
#     countries: pd.DataFrame = wb.get_countries()

#     st.dataframe(countries)

# # the with statment shows the code for this block above it
# with st.echo(code_location='above'):
#     arr = np.random.normal(1, 1, size=100)
#     test_plot, ax = plt.subplots()
#     ax.hist(arr, bins=20)

#     st.pyplot(test_plot)


# with st.echo(code_location='above'):
#     slim_countries = countries[countries['incomeLevel'] != 'Aggregates']
#     data_crosstab = pd.crosstab(slim_countries['region'],
#                                 slim_countries['incomeLevel'],
#                                 margins=False)
#     st.table(data_crosstab)
