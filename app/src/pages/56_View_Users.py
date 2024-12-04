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


st.header("All Users:")
st.markdown("---")
users = requests.get(f'http://api:4000/u/users').json()


for user in users:
    st.write(f"### {user['Name']}")
    st.write(f"**Email:** {user['Email']}")
    st.write(f"**Phone Number:** {user['PhoneNumber']}")
    st.write(f"**Status:** {user['Status']}")
    st.write(f"**User Type:** {user['UserType']}")
    st.write(f"**Date Created:** {format_date(user['DateCreated'])}")
    st.write(f"**Last Login:** {format_date(user['LastLogin'])}")
    st.write(f"**UUID:** {user['UUID']}")
    st.markdown("---")
