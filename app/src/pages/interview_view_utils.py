from datetime import datetime
import streamlit as st
import requests

def format_date(date_str):
    date = datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S %Z")
    return date.strftime("%d %b %Y")

##Framework for rendering an interview, takes in a json version of an interview entity
def render_interview(interview):
    col1, col2 = st.columns([1, 2])
    
    Student= requests.get(f"http://api:4000/u/users/{interview['StudentId']}").json()[0]
    
    with col1:
        st.subheader("Student")
        st.write(f"{Student['Name']}")
    Company= requests.get(f"http://api:4000/c/companies/{interview['CompanyId']}").json()[0]
    with col2:
        st.subheader("Company")
        st.write(f"{Company['Name']}")
        st.write(f"{format_date(interview['InterviewDate'])}")

    st.markdown("---")
