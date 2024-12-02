import logging
import requests
import streamlit as st
from modules.nav import SideBarLinks
from datetime import datetime

logger = logging.getLogger(__name__)

SideBarLinks()
st.header(f"Hi, {st.session_state['first_name']}.")

def format_date(date):
    date = datetime.strptime(date, "%a, %d %b %Y %H:%M:%S %Z")
    return date.strftime("%d %b %Y")


st.header("All Companies:")
st.markdown("---")
companies = requests.get(f'http://api:4000/c/companies').json()

for company in companies:
    st.write(f"### {company['Name']}")
    st.write(f"**Location:** {company['City']}, {company['State']}, {company['Country']}")
    st.write(f"**Accepts International Students:** {'True' if company['AcceptsInternational'] else 'False'}")
    st.write(f"**Is Active:** {'True' if company['isActive'] else 'False'}")
    st.write(f"**ID:** {company['Id']}")
    st.markdown("---")

