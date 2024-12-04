# Idea borrowed from https://github.com/fsmosca/sample-streamlit-authenticator

# This file has function to add certain functionality to the left side bar of the app

import streamlit as st


# ------------------------ General ------------------------
def HomeNav():
    st.sidebar.page_link("Home.py", label="Home", icon="🏠")


def AboutPageNav():
    st.sidebar.page_link("pages/30_About.py", label="About", icon="🧠")


# ------------------------ Examples for Role of pol_strat_advisor ------------------------
def PolStratAdvHomeNav():
    st.sidebar.page_link(
        "pages/00_Pol_Strat_Home.py", label="Political Strategist Home", icon="👤"
    )


def WorldBankVizNav():
    st.sidebar.page_link(
        "pages/01_World_Bank_Viz.py", label="World Bank Visualization", icon="🏦"
    )


def MapDemoNav():
    st.sidebar.page_link("pages/02_Map_Demo.py",
                         label="Map Demonstration", icon="🗺️")


# ------------------------ Examples for Role of usaid_worker ------------------------
def ApiTestNav():
    st.sidebar.page_link("pages/12_API_Test.py",
                         label="Test the API", icon="🛜")


def PredictionNav():
    st.sidebar.page_link(
        "pages/11_Prediction.py", label="Regression Prediction", icon="📈"
    )


def ClassificationNav():
    st.sidebar.page_link(
        "pages/13_Classification.py", label="Classification Demo", icon="🌺"
    )


# ------------------------ System Admin Role ------------------------
def AdminPageNav():
    st.sidebar.page_link("pages/20_Admin_Home.py",
                         label="System Admin", icon="🖥️")
    st.sidebar.page_link(
        "pages/21_ML_Model_Mgmt.py", label="ML Model Management", icon="🏢"
    )

# ************
# All Personas
# ************


def view_companies_page_nav():
    st.sidebar.page_link("pages/66_View_Companies.py",
                         label="View Companies", icon="🏢")


# *********
# Recruiter
# *********
def recruiter_home_nav():
    st.sidebar.page_link(
        "pages/40_Recruiter_Home.py", label="Recruiter Home", icon="👤"
    )


def view_specific_resumes_page_nav():
    st.sidebar.page_link("pages/41_Resume_List.py",
                         label="Specific Resumes", icon="📚")


def view_my_companies_page_nav():
    st.sidebar.page_link("pages/77_Company_Info.py",
                         label="View My Companies Profile", icon="💼")


def view_students_at_company_nav():
    st.sidebar.page_link("pages/78_Student_At_Same_Company_As_Recruiter.py",
                         label="View Previous/Current Co-ops", icon="📝")


def view_selecting_interviewees_nav():
    st.sidebar.page_link("pages/79_Select_Interview.py",
                         label="Select Interviewees", icon="👨‍💻")


def view_delete_interviews_nav():
    st.sidebar.page_link("pages/80_Delete_Interview.py",
                         label="Delete Interviews", icon="🗑️")


def view_future_interviews_nav():
    st.sidebar.page_link("pages/81_Future_Interviews.py",
                         label="Future Interviews", icon="🗓️")


# ************
# System Admin
# ************
def system_admin_home_nav():
    st.sidebar.page_link(
        "pages/50_System_Admin_Home.py", label="System Admin Home", icon="👤")


def view_users_page_nav():
    st.sidebar.page_link("pages/56_View_Users.py",
                         label="View Users", icon="👀")


def view_resumes_page_nav():
    st.sidebar.page_link("pages/63_View_Resumes.py",
                         label="View Resumes", icon="📄")


def view_skills_page_nav():
    st.sidebar.page_link("pages/51_View_Skills.py",
                         label="View Skills", icon="🛠️")


def update_companies_page_nav():
    st.sidebar.page_link("pages/52_Update_Company_Info.py",
                         label="Update Company Info", icon="🔄")


def delete_resumes_page_nav():
    st.sidebar.page_link("pages/53_Delete_Resume.py",
                         label="Delete Resume", icon="🗑️")


def delete_company_page_nav():
    st.sidebar.page_link("pages/54_Delete_Company.py",
                         label="Delete Company", icon="❌")


def delete_user_page_nav():
    st.sidebar.page_link("pages/55_Delete_User.py",
                         label="Delete User", icon="🔥")


# *******
# Student
# *******
def student_home_nav():
    st.sidebar.page_link("pages/60_Student_Home.py",
                         label="Student Home", icon="👤")


def student_add_resume():
    st.sidebar.page_link("pages/61_Add_Resume.py",
                         label="Add Resume", icon="🧾")


def student_update_resume():
    st.sidebar.page_link('pages/62_Update_Resume.py',
                         label="Update Resume", icon="✏️")


def student_view_resumes():
    st.sidebar.page_link('pages/63_View_Resumes.py',
                         label="View All Resumes", icon="📑")


def student_add_interview():
    st.sidebar.page_link('pages/64_Add_Interview.py',
                         label="Add Interview", icon="🥊")


def student_view_resumes_by_company():
    st.sidebar.page_link('pages/65_View_Resumes_By_Company.py',
                         label="View Resumes by Company", icon="👨‍🏫")


# *************
# Co-op Advisor
# *************
def coop_advisor_home_nav():
    st.sidebar.page_link("pages/70_Coop_Advisor_Home.py",
                         label="Coop Advisor Home", icon="👤")


def coop_advisor_view_resumes_by_degree():
    st.sidebar.page_link("pages/71_View_Resumes_By_Degree.py",
                         label="View Resumes By Degree", icon="📜")


def coop_advisor_view_resumes_by_interview_at_company():
    st.sidebar.page_link("pages/73_View_Resumes_By_Interview_At_Company.py",
                         label="Resumes Landed Interviews", icon="👁️")


def coop_advisor_view_resumes_by_experience():
    st.sidebar.page_link("pages/74_View_Resumes_By_Experience.py",
                         label="Search by # Experiences", icon="#️⃣️")


def coop_advisor_view_interviews_by_student():
    st.sidebar.page_link("pages/75_View_Interviews_By_Student.py",
                         label="My Students' Interviews", icon="👀")


def coop_advisor_view_resumes_by_advisor():
    st.sidebar.page_link("pages/76_View_Resumes_By_Advisor.py",
                         label="My Students' Resumes", icon="📃")


# --------------------------------Links Function -----------------------------------------------
def SideBarLinks(show_home=False):
    """
    This function handles adding links to the sidebar of the app based upon the logged-in user's role, which was put in the streamlit session_state object when logging in.
    """

    # add a logo to the sidebar always
    st.sidebar.image("assets/logo.png", width=325)

    # If there is no logged in user, redirect to the Home (Landing) page
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False
        st.switch_page("Home.py")

    if show_home:
        # Show the Home page link (the landing page)
        HomeNav()

    # Show the other page navigators depending on the users' role.
    if st.session_state["authenticated"]:
        # These are the personas from the starter code.
        # Show World Bank Link and Map Demo Link if the user is a political strategy advisor role.
        if st.session_state["role"] == "pol_strat_advisor":
            PolStratAdvHomeNav()
            WorldBankVizNav()
            MapDemoNav()

        # If the user role is usaid worker, show the Api Testing page
        if st.session_state["role"] == "usaid_worker":
            PredictionNav()
            ApiTestNav()
            ClassificationNav()

        # If the user is an administrator, give them access to the administrator pages
        if st.session_state["role"] == "administrator":
            AdminPageNav()

        # ********************
        # These are our roles.
        # ********************
        if st.session_state["role"] == "recruiter":
            recruiter_home_nav()
            view_specific_resumes_page_nav()
            view_resumes_page_nav()
            view_companies_page_nav()
            view_my_companies_page_nav()
            view_students_at_company_nav()
            view_selecting_interviewees_nav()
            view_future_interviews_nav()
            view_delete_interviews_nav()

        if st.session_state["role"] == "system_admin":
            system_admin_home_nav()
            view_users_page_nav()
            view_resumes_page_nav()
            view_companies_page_nav()
            view_skills_page_nav()
            update_companies_page_nav()
            delete_resumes_page_nav()
            delete_company_page_nav()
            delete_user_page_nav()

        if st.session_state["role"] == "student":
            student_home_nav()
            student_add_resume()
            student_update_resume()
            delete_resumes_page_nav()
            student_view_resumes()
            student_add_interview()
            student_view_resumes_by_company()
            view_companies_page_nav()

        if st.session_state["role"] == "coop_advisor":
            coop_advisor_home_nav()
            student_view_resumes_by_company()
            coop_advisor_view_resumes_by_degree()
            coop_advisor_view_resumes_by_interview_at_company()
            coop_advisor_view_resumes_by_experience()
            coop_advisor_view_interviews_by_student()
            coop_advisor_view_resumes_by_advisor()
            view_companies_page_nav()

    # Always show the About page at the bottom of the list of links
    AboutPageNav()

    if st.session_state["authenticated"]:
        # Always show a logout button if there is a logged in user
        if st.sidebar.button("Logout"):
            del st.session_state["role"]
            del st.session_state["authenticated"]
            st.switch_page("Home.py")
