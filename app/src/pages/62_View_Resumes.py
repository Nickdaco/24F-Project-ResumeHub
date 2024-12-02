import logging
import streamlit as st
from modules.nav import SideBarLinks
import json
from datetime import datetime


logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
import streamlit as st
import json

# test json
resumes = [
    {
        "City": "Boston",
        "Country": "USA",
        "DateCreated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "Education": [
            {
                "Degree": "B.S. Computer Science",
                "Description": "Studied Computer Science with a focus on software systems and AI.",
                "EndDate": "Wed, 15 May 2024 00:00:00 GMT",
                "Institution": "Stanford University",
                "StartDate": "Tue, 01 Sep 2020 00:00:00 GMT"
            }
        ],
        "Email": "davidscott@example.com",
        "Experience": [
            {
                "CompanyName": "Snap Inc.",
                "Description": "Led frontend team in building new user features for Snapchat.",
                "EndDate": "Fri, 30 Jun 2023 00:00:00 GMT",
                "StartDate": "Fri, 01 Jul 2022 00:00:00 GMT",
                "Title": "Frontend Developer"
            },
            {
                "CompanyName": "HubSpot",
                "Description": "Developed customer service solutions, integrated chatbots with CRM tools.",
                "EndDate": "Sat, 01 Jun 2024 00:00:00 GMT",
                "StartDate": "Thu, 01 Jun 2023 00:00:00 GMT",
                "Title": "Software Engineer"
            }
            ],
        "GithubLink": "https://github.com/davidscott",
        "GraduationYear": 2024,
        "LastUpdated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "LinkedInLink": "https://linkedin.com/in/davidscott",
        "Name": "David Scott",
        "ResumeID": 11,
        "Skills": [
            {
                "Name": "Data Analysis",
                "Proficiency": "Expert"
            }
        ],
        "State": "MA",
        "University": "Harvard University"
    },
    {
        "City": "San Francisco",
        "Country": "USA",
        "DateCreated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "Education": [],
        "Email": "zoeytaylor@example.com",
        "Experience": [
            {
                "CompanyName": "HubSpot",
                "Description": "Developed customer service solutions, integrated chatbots with CRM tools.",
                "EndDate": "Sat, 01 Jun 2024 00:00:00 GMT",
                "StartDate": "Thu, 01 Jun 2023 00:00:00 GMT",
                "Title": "Software Engineer"
            }
        ],
        "GithubLink": "https://github.com/zoeytaylor",
        "GraduationYear": 2024,
        "LastUpdated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "LinkedInLink": "https://linkedin.com/in/zoeytaylor",
        "Name": "Zoey Taylor",
        "ResumeID": 12,
        "Skills": [
            {
                "Name": "Cloud Computing",
                "Proficiency": "Intermediate"
            }
        ],
        "State": "CA",
        "University": "Stanford University"
    },
        {
        "City": "San Francisco",
        "Country": "USA",
        "DateCreated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "Education": [],
        "Email": "zoeytaylor@example.com",
        "Experience": [
            {
                "CompanyName": "HubSpot",
                "Description": "Developed customer service solutions, integrated chatbots with CRM tools.",
                "EndDate": "Sat, 01 Jun 2024 00:00:00 GMT",
                "StartDate": "Thu, 01 Jun 2023 00:00:00 GMT",
                "Title": "Software Engineer"
            },
                        {
                "CompanyName": "HubSpot",
                "Description": "Developed customer service solutions, integrated chatbots with CRM tools.",
                "EndDate": "Sat, 01 Jun 2024 00:00:00 GMT",
                "StartDate": "Thu, 01 Jun 2023 00:00:00 GMT",
                "Title": "Software Engineer"
            }
        ],
        "GithubLink": "https://github.com/zoeytaylor",
        "GraduationYear": 2024,
        "LastUpdated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "LinkedInLink": "https://linkedin.com/in/zoeytaylor",
        "Name": "Zoey Taylor",
        "ResumeID": 12,
        "Skills": [
            {
                "Name": "Cloud Computing",
                "Proficiency": "Intermediate"
            }
        ],
        "State": "CA",
        "University": "Stanford University"
    },
        {
        "City": "San Francisco",
        "Country": "USA",
        "DateCreated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "Education": [],
        "Email": "zoeytaylor@example.com",
        "Experience": [
            {
                "CompanyName": "HubSpot",
                "Description": "Developed customer service solutions, integrated chatbots with CRM tools.",
                "EndDate": "Sat, 01 Jun 2024 00:00:00 GMT",
                "StartDate": "Thu, 01 Jun 2023 00:00:00 GMT",
                "Title": "Software Engineer"
            }
        ],
        "GithubLink": "https://github.com/zoeytaylor",
        "GraduationYear": 2024,
        "LastUpdated": "Mon, 02 Dec 2024 21:19:16 GMT",
        "LinkedInLink": "https://linkedin.com/in/zoeytaylor",
        "Name": "Zoey Taylor",
        "ResumeID": 12,
        "Skills": [
            {
                "Name": "Cloud Computing",
                "Proficiency": "Intermediate"
            }
        ],
        "State": "CA",
        "University": "Stanford University"
    }
]

def format_date(date):
    date = datetime.strptime(date, "%a, %d %b %Y %H:%M:%S %Z")
    return date.strftime("%d %b %Y")

st.header("Resumes:")

st.markdown("---")

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
