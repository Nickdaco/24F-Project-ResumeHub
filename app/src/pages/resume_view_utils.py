from datetime import datetime
import streamlit as st

def format_date(date_str):
    date = datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S %Z")
    return date.strftime("%d %b %Y")

def render_resume(resume):
    st.write(f"## {resume['Name']}")
    st.write(f"**Resume Id:** {resume['ResumeID']}")
    col1, col2 = st.columns([1, 2])

    with col1:
        st.subheader("Contact Info")
        st.write(f"**City:** {resume['City']}, {resume['State']}, {resume['Country']}")
        st.write(f"**Email:** {resume['Email']}")
        st.write(f"**GitHub:** [GitHub Profile]({resume['GithubLink']})")
        st.write(f"**LinkedIn:** [LinkedIn Profile]({resume['LinkedInLink']})")

    with col2:
        if resume.get("Education"):
            st.subheader("Education:")
            for i, edu in enumerate(resume["Education"]):
                if len(resume["Education"]) > 1:
                    st.write(f"#### Education {i + 1}")
                st.write(f"- {edu['Degree']} from {edu['Institution']}")
                st.write(f"- {format_date(edu['StartDate'])} to {format_date(edu['EndDate'])}")
                st.write(f"- {edu['Description']}")

        if resume.get("Experience"):
            st.subheader("Experience:")
            for i, exp in enumerate(resume["Experience"]):
                if len(resume["Experience"]) > 1:
                    st.write(f"#### Experience {i + 1}")
                st.write(f"- {exp['Title']} at {exp['CompanyName']}")
                st.write(f"- {format_date(exp['StartDate'])} to {format_date(exp['EndDate'])}")
                st.write(f"- {exp['Description']}")

        if resume.get("Skills"):
            st.subheader("Skills")
            for skill in resume["Skills"]:
                st.write(f"- {skill['Name']}: {skill['Proficiency']}")

    st.markdown("---")
