from modules.nav import SideBarLinks
import streamlit as st

SideBarLinks()


st.header(f"{st.session_state['resume_info']['Name']}'s Resume")
for eduction in st.session_state['resume_info']['Education']:
    st.write(f"### University: {eduction['Institution']}")
    st.write(f"Type of Degree: {eduction['Degree']}")
    st.write(f"From: {eduction['StartDate']} - To: {eduction['EndDate']}")
    st.write(f"Description: {eduction['Description']}")
    st.write("")

st.divider()

for experience in st.session_state['resume_info']['Experience']:
    st.write(f"### Company Name: {experience['CompanyName']}")
    st.write(f"Title: {experience['Title']}")
    st.write(f"From: {experience['StartDate']} - To: {eduction['EndDate']}")
    st.write(f"Description: {experience['Description']}")
    st.write("")

st.divider()

for skill in st.session_state['resume_info']['Skills']:
    st.write(f"### Skill Name: {skill['Name']}")
    st.write(f"Proficiency: {skill['Proficiency']}")
    st.write("")

st.divider()

st.write("### Links/Contact Info")
st.write(st.session_state['resume_info']['GithubLink'])
st.write(st.session_state['resume_info']['LinkedInLink'])
st.write(st.session_state['resume_info']['Email'])
st.divider()
st.write("### Location")
st.write(f"{st.session_state['resume_info']['City']}, \
         {st.session_state['resume_info']['State']}, {st.session_state['resume_info']['Country']}")
