import streamlit as st
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

SideBarLinks()

st.write("# About this App")

st.markdown (
    """
    This is ResumeHub a platform meant to transform the resume building experience. 
    
    Students will enjoy a variety of features meant to help show them what resumes
    find success at a variety of companies to better understand the skills and 
    experiences that they need to cultivate. 

    Coop advisors will be able to track their students interviews and resumes in
    order to assist them in their goals.

    Recruiters will be able to verify interviews with their company and find
    prospective candidates amoung the students.

    Finally admins will be able to manage all this information in order to ensure reliability
    and integrity of the data.   
    """
        )
