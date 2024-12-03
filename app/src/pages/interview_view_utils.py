from datetime import datetime
import streamlit as st


def render_resume(interview):
    col1, col2 = st.columns([1, 2])

    with col1:
        st.subheader("Student")
        st.write(f"{interview['Student']}")

    with col2:
        st.subheader("Company")
        st.write(f"{interview['Company']}")
        st.write(f"{interview["Date"]}")

    st.markdown("---")
