from modules.nav import SideBarLinks
import streamlit as st

SideBarLinks()
# st.set_page_config(layout='centered')


st.header(f"{st.session_state['resume_info']['resume_name']}'s Resume")
# st.write(st.session_state['resume_name']['resume_name'])
for eduction in st.session_state['resume_info']['eduction_info']:
    # st.write(f"{eduction}")
    st.write(f"### Name: {eduction['name']}")
    st.write(f"Type of Degree: {eduction['degree']}")
    st.write(f"Field of Study: {eduction['Field']}")
    st.write(f"From: {eduction['StartDate']} - To: {eduction['EndDate']}")
    st.write(f"Description: {eduction['Description']}")
    st.write("")
    # st.write("")
st.divider()

for experience in st.session_state['resume_info']['experience_info']:
    # st.write(f"{eduction}")
    st.write(f"### Company Name: {experience['company_name']}")
    st.write(f"Title: {experience['position_title']}")
    st.write(f"From: {experience['StartDate']} - To: {eduction['EndDate']}")
    st.write(f"City: {experience['city']}, State: {experience['state']}")
    st.write(f"Description: {experience['Description']}")
    st.write("")
    # st.write("")

st.divider()

for skill in st.session_state['resume_info']['skills_info']:
    st.write(f"### Skill Name: {skill['name']}")
    st.write(f"Proficiency: {skill['proficiency']}")
    st.write("")
    # st.write("")
