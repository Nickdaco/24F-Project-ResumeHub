import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from pages.resume_view_utils import render_resume

logger = logging.getLogger(__name__)


SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")
st.header("View your companies info")

# The UUID changes each time the docker container starts, rather than implement a log in system to mitigate this
# (and also break the rules of the project) We elected to search for the UUID instead.


def render_company(company):
    st.write(f"Company Name: {company['Name']}")
    st.write(f"{company['City']}, {company['State']}, {company['Country']}")
    st.write(f"Accepts International Students: \
             {company['AcceptsInternational'] == 1}")
    st.write(f"Is Currently Active: {company['isActive'] == 1}")
    st.divider()


def getId():
    all_users = requests.get(f'http://api:4000/u/users').json()
    recruiter_id = "INVALID"
    for user in all_users:
        if user["Name"] == st.session_state['full_name']:
            recruiter_id = user["UUID"]
    return recruiter_id


recruiter_id = getId()

companies = requests.get(
    f'http://api:4000/c/companies/recruiter/{recruiter_id}').json()
for company in companies:
    render_company(company)
