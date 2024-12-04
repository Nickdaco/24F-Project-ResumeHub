##################################################
# This is the main/entry-point file for the
# sample application for your project
##################################################

# Set up basic logging infrastructure
from modules.nav import SideBarLinks
import streamlit as st
import logging
logging.basicConfig(
    format='%(filename)s:%(lineno)s:%(levelname)s -- %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# import the main streamlit library as well
# as SideBarLinks function from src/modules folder

# streamlit supports reguarl and wide layout (how the controls
# are organized/displayed on the screen).
st.set_page_config(layout='wide')

# If a user is at this page, we assume they are not
# authenticated.  So we change the 'authenticated' value
# in the streamlit session_state to false.
st.session_state['authenticated'] = False

# Use the SideBarLinks function from src/modules/nav.py to control
# the links displayed on the left-side panel.
# IMPORTANT: ensure src/.streamlit/config.toml sets
# showSidebarNavigation = false in the [client] section
SideBarLinks(show_home=True)

# ***************************************************
#    The major content of this page
# ***************************************************

# set the title of the page and provide a simple prompt.
logger.info("Loading the Home page of the app")
st.title('ResumeHub')
st.write('\n\n')
st.write('### Hi! As which user would you like to log in?')

# For each of the user personas for which we are implementing
# functionality, we put a button on the screen that the user
# can click to MIMIC logging in as that mock user.

# **********************
# These are our personas
# **********************
if st.button('Act as Anna, a tech recruiter', type='primary', use_container_width=True):
    st.session_state['authenticated'] = True
    st.session_state['role'] = 'recruiter'
    st.session_state['first_name'] = 'Anna'
    st.session_state['full_name'] = "Anna Bell"
    st.switch_page('pages/40_Recruiter_Home.py')

if st.button('Act as Leviticus, a system administrator', type='primary', use_container_width=True):
    st.session_state['authenticated'] = True
    st.session_state['role'] = 'system_admin'
    st.session_state['first_name'] = 'Leviticus'
    st.switch_page('pages/50_System_Admin_Home.py')

if st.button('Act as Kyle, a student', type='primary', use_container_width=True):
    st.session_state['authenticated'] = True
    st.session_state['role'] = 'student'
    st.session_state['first_name'] = 'Kyle'
    st.switch_page('pages/60_Student_Home.py')

if st.button('Act as Sam, a co-op advisor', type='primary', use_container_width=True):
    st.session_state['authenticated'] = True
    st.session_state['role'] = 'coop_advisor'
    st.session_state['first_name'] = 'Sam'
    st.switch_page('pages/70_Coop_Advisor_Home.py')
