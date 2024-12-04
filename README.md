# ResumeHub Repository
ResumeHub is a data-driven platform designed to transform the job search process for students, advisors, and recruiters. By providing a central resume database that highlights which resumes are securing interviews, ResumeHub helps students understand the skills, formats, and experiences that attract recruiter interest. This platform alleviates the current inefficiencies where students, advisors, and recruiters manually collect and analyze resume data, which often proves time-consuming and unscalable. With ResumeHub, users gain valuable insights without the hassle, improving decision-making for job-seeking students and their advisors.

The platform supports four primary user types—students, co-op advisors, recruiters, and system administrators—each benefiting from tailored features. Students can view peer resumes that have succeeded in similar applications, helping them optimize their own. Advisors gain insights into which resumes are landing interviews, allowing them to make data-informed recommendations to students. Recruiters benefit from filtering resumes by skills and reviewing past successful candidates, simplifying the resume screening process. Lastly, system administrators ensure the platform remains reliable by removing outdated or suspicious content. Key features include a searchable resume database, a trend-spotting analytics dashboard, and a streamlined resume upload process that keeps profiles updated and accessible, making the journey to employment more informed and efficient.

## Current Project Components

Currently, there are three major components which will each run in their own Docker Containers:

- Streamlit App in the `./app` directory
- Flask REST api in the `./api` directory
- SQL files for our data model and data base in the `./database-files` directory


# Running the app
In order to locally host the website you must first pull this repo. Locate the /api/.env.template file and remove '.template'. Supply a password of your choice for example 'Money123!' in the MYSQL_ROOT_PASSWORD field. 
Next run the following lines of code in the terminal
 - docker compose build 
 - docker compose up -d
Finally, open the browser of your choice to http://localhost:8501

# Authors
This project was built by Dylan Cerenov,Nicholas Mamisashvili, Ryan Tietjen, Aidan Gilchrist, and Daniel Kaplan

 
 
