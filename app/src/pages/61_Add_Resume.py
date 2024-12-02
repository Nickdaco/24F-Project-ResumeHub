import logging

import requests
import streamlit as st
from modules.nav import SideBarLinks
import json

logger = logging.getLogger(__name__)

SideBarLinks()

st.header(f"Hi, {st.session_state['first_name']}.")
st.header('Add new resume')

def add_entry(session_state_key):
    entry = {}
    for field in st.session_state[f'{session_state_key}_fields']:
        value = st.session_state[f'{session_state_key}_{field}']
        if field in ['StartDate', 'EndDate'] and value:
            entry[field] = value.strftime('%Y-%m-%d')
        else:
            entry[field] = value
    st.session_state[session_state_key].append(entry)


def remove_entry(session_state_key, index):
    del st.session_state[session_state_key][index]

if 'skills' not in st.session_state:
    st.session_state.skills = []
if 'education' not in st.session_state:
    st.session_state.education = []
if 'experience' not in st.session_state:
    st.session_state.experience = []

def render_list_section(section_key, fields, section_title):
    st.write(f"#### {section_title}")
    
    if st.session_state[section_key]:
        for idx, entry in enumerate(st.session_state[section_key]):
            col1, col2 = st.columns([3, 1])
            with col1:
                for key, value in entry.items():
                    st.write(f"**{key}:** {value}")
            with col2:
                if st.button(f"Remove {section_title} {idx+1}", key=f"remove_{section_key}_{idx}"):
                    remove_entry(section_key, idx)
                    st.rerun()
    
    with st.form(f"{section_key}_form"):
        st.write(f"Add New {section_title}")
        for field in fields:
            if field == 'EndDate':
                st.checkbox("Currently Ongoing", key=f"{section_key}_is_current")
                if not st.session_state.get(f"{section_key}_is_current", False):
                    st.date_input(field, key=f"{section_key}_{field}")
            elif field in ['StartDate', 'EndDate']:
                st.date_input(field, key=f"{section_key}_{field}")
            else:
                st.text_input(field, key=f"{section_key}_{field}")
        
        st.session_state[f'{section_key}_fields'] = fields
        submitted = st.form_submit_button(f"Add {section_title}")
        if submitted:
            if section_key == 'experience' and st.session_state.get(f"{section_key}_is_current", False):
                st.session_state[f'{section_key}_EndDate'] = None
            add_entry(section_key)
            st.rerun()

def generate_final_json():
    return {
        "StudentId": st.session_state.student_id,
        "Name": st.session_state.name,
        "Email": st.session_state.email,
        "City": st.session_state.city,
        "State": st.session_state.state,
        "Country": st.session_state.country,
        "Skills": st.session_state.skills,
        "Education": st.session_state.education,
        "Experience": st.session_state.experience
    }

st.text_input("Student ID", key="student_id")
st.write("#### Contact Information")
col1, col2 = st.columns(2)
with col1:
    st.text_input("Name", key="name")
    st.text_input("Email", key="email")
with col2:
    st.text_input("City", key="city")
    st.text_input("State", key="state")
    st.text_input("Country", key="country")

render_list_section('skills', ['Name', 'Proficiency'], 'Skills')
render_list_section('education', ['Institution', 'Degree', 'StartDate', 'EndDate', 'Description'], 'Education')
render_list_section('experience', ['CompanyName', 'Title', 'StartDate', 'EndDate', 'Description', 'City', 'State'], 'Experience')

if st.button("Upload Resume"):
    final_json = generate_final_json()
    st.json(final_json)

    headers = {'Content-Type': 'application/json'}
    response = requests.post(
        "http://api:4000/r/resumes",
        headers=headers,
        data=json.dumps(final_json).encode(),
    )
    response.raise_for_status()

    # st.switch_page("pages/60_Student_Home.py")
