import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from datetime import datetime

logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
import streamlit as st


def format_date(date):
    date = datetime.strptime(date, "%a, %d %b %Y %H:%M:%S %Z")
    return date.strftime("%d %b %Y")

st.header("Resumes:")
st.markdown("---")
resumes = requests.get(f'http://api:4000/r/resumes').json()

for resume in resumes:
    st.write(f"## {resume['Name']}")
    col1, col2 = st.columns([1, 2]) 

    with col1:
        st.subheader("Contact Info")
        st.write(f"**City:** {resume['City']}, {resume['State']}, {resume['Country']}")
        st.write(f"**Email:** {resume['Email']}")
        st.write(f"**GitHub:** [GitHub Profile]({resume['GithubLink']})")
        st.write(f"**LinkedIn:** [LinkedIn Profile]({resume['LinkedInLink']})")

    with col2:
        if resume["Education"]:
            st.subheader("Education:")
            for i in range(len(resume["Education"])):
                edu = resume["Education"][i]
                if len(resume['Education']) > 1:
                    st.write(f"#### Education {i + 1}")
                st.write(f"- {edu['Degree']}** from {edu['Institution']}")
                st.write(f"- {format_date(edu['StartDate'])} to {format_date(edu['EndDate'])}")
                st.write(f"- {edu['Description']}")

        if resume["Experience"]:
            st.subheader("Experience:")
            for i in range(len(resume["Experience"])):
                exp = resume["Experience"][i]
                if len(resume['Experience']) > 1:
                    st.write(f"#### Experience {i + 1}")
                st.write(f"- {exp['Title']} at {exp['CompanyName']}")
                st.write(f"- {format_date(exp['StartDate'])} to {format_date(exp['EndDate'])}")
                st.write(f"- {exp['Description']}")

        if resume["Skills"]:
            st.subheader("Skills")
            for skill in resume["Skills"]:
                st.write(f"- {skill['Name']}: {skill['Proficiency']}")

    st.markdown("---")
