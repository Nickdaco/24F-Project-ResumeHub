# ResumeHub Repository
ResumeHub is a data-driven platform designed to transform the job search process for students, advisors, and recruiters. By providing a central resume database that highlights which resumes are securing interviews, ResumeHub helps students understand the skills, formats, and experiences that attract recruiter interest. This platform alleviates the current inefficiencies where students, advisors, and recruiters manually collect and analyze resume data, which often proves time-consuming and unscalable. With ResumeHub, users gain valuable insights without the hassle, improving decision-making for job-seeking students and their advisors.

The platform supports four primary user types—students, co-op advisors, recruiters, and system administrators—each benefiting from tailored features. Students can view peer resumes that have succeeded in similar applications, helping them optimize their own. Advisors gain insights into which resumes are landing interviews, allowing them to make data-informed recommendations to students. Recruiters benefit from filtering resumes by skills and reviewing past successful candidates, simplifying the resume screening process. Lastly, system administrators ensure the platform remains reliable by removing outdated or suspicious content. Key features include a searchable resume database, a trend-spotting analytics dashboard, and a streamlined resume upload process that keeps profiles updated and accessible, making the journey to employment more informed and efficient.

## Current Project Components

Currently, there are three major components which will each run in their own Docker Containers:

- Streamlit App in the `./app` directory
    - all pages can be found in `./app/src/pages each page has a prefix as a number for file management
        - 30 an about page for the app
        - 40-49 Recruiter Pages
        - 50-59 System Admin pages
        - 60-69 Student pages
        - 70-79 Coop Advisor
        - 80-89 Interview pages
    # Note: Some pages such as 65_View_Resumes_By_Company are shared between users, in this case Advisor and Student.  
- Flask REST api in the `./api` directory
    - all blueprints can be found under `/api/backend/resume_hub_blueprints`
        - /companies: all routes for managing the company data
        - /interviews: all routes for managing the interview data
        - /resumes: all routes for managing the resume data and a route to find all students for the purposes of finding their resumes
        - /users: for all other routes having to do with users
- SQL files for our data model and data base in the `./database-files` directory


# Running the app
In order to locally host the website you must first pull this repo. Locate the /api/.env.template file and remove '.template'. Supply a password of your choice for example 'Money123!' in the MYSQL_ROOT_PASSWORD field. 
Next run the following lines of code in the terminal
 - docker compose build 
 - docker compose up -d
Finally, open the browser of your choice to http://localhost:8501

# Authors
This project was built by Dylan Cerenov, Nicholas Mamisashvili, Ryan Tietjen, Aidan Gilchrist, and Daniel Kaplan

# UUID Issues
We used UUID for the user in order to make the app as scaleable as possible. Unfortunately the UUID changes each time the docker container restarts. Due to this we were unable to set the userId as part of the login, we developed a workaround to search for the userid by name which would not be done in a fully fleshed out version of this app.
 
