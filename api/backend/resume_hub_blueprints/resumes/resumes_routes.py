from flask import Blueprint
from flask import jsonify
from flask import make_response
from backend.db_connection import db

resumes = Blueprint('resumes', __name__)


# Helper function to convert SQL rows into a JSON object.
def combine_multiple_rows_into_json_object(the_data):
    resumes_dict = {}

    # Deserialize the data into this dict.
    for row in the_data:
        resume_id = row['ResumeID']

        if resume_id not in resumes_dict:
            resumes_dict[resume_id] = {
                "ResumeID": resume_id,
                "Name": row['ResumeName'],
                "Email": row['ResumeEmail'],
                "City": row['ResumeCity'],
                "State": row['ResumeState'],
                "Country": row['ResumeCountry'],
                "DateCreated": row['ResumeDateCreated'],
                "LastUpdated": row['ResumeLastUpdated'],
                "GithubLink": row['StudentGithubLink'],
                "LinkedInLink": row['StudentLinkedInLink'],
                "University": row['StudentUniversity'],
                "GraduationYear": row['StudentGraduationYear'],
                "City": row['StudentCity'],
                "State": row['StudentState'],
                "Skills": set(),  # Set to avoid dupes
                "Experience": set(),
                "Education": set()
            }

        if row['SkillName']:
            resumes_dict[resume_id]['Skills'].add((row['SkillName'], row['SkillProficiency']))

        if row['ExperienceCompanyName']:
            resumes_dict[resume_id]['Experience'].add((
                row['ExperienceCompanyName'],
                row['ExperienceTitle'],
                row['ExperienceStartDate'],
                row['ExperienceEndDate'],
                row['ExperienceDescription']
            ))

        if row['EducationInstitution']:
            resumes_dict[resume_id]['Education'].add((
                row['EducationInstitution'],
                row['EducationDegree'],
                row['EducationStartDate'],
                row['EducationEndDate'],
                row['EducationDescription']
            ))

    # After all the data has been put in the dict
    # This is necessary to turn the sets into JSON serializable objects.
    for resume_id in resumes_dict:
        resume = resumes_dict[resume_id]
        resume['Skills'] = [
            {'Name': skill[0], 'Proficiency': skill[1]} for skill in resume['Skills']
        ]
        resume['Experience'] = [
            {
                'CompanyName': exp[0],
                'Title': exp[1],
                'StartDate': exp[2],
                'EndDate': exp[3],
                'Description': exp[4]
            } for exp in resume['Experience']
        ]
        resume['Education'] = [
            {
                'Institution': edu[0],
                'Degree': edu[1],
                'StartDate': edu[2],
                'EndDate': edu[3],
                'Description': edu[4]
            } for edu in resume['Education']
        ]

    return list(resumes_dict.values())


# GET /resumes
@resumes.route('/resumes', methods=['GET'])
def get_resumes():
    cursor = db.get_db().cursor()
    cursor.execute('''
    SELECT DISTINCT
        r.ResumeId AS ResumeID,
        r.Name AS ResumeName,
        r.Email AS ResumeEmail,
        r.City AS ResumeCity,
        r.State AS ResumeState,
        r.Country AS ResumeCountry,
        r.DateCreated AS ResumeDateCreated,
        r.LastUpdated AS ResumeLastUpdated,
        s.GithubLink AS StudentGithubLink,
        s.LinkedInLink AS StudentLinkedInLink,
        s.University AS StudentUniversity,
        s.GraduationYear AS StudentGraduationYear,
        s.CurrentCity AS StudentCity,
        s.CurrentState AS StudentState,
        u.Name AS StudentName,
        u.Email AS StudentEmail,
        sk.Name AS SkillName,
        sk.Proficiency AS SkillProficiency,
        ex.CompanyName AS ExperienceCompanyName,
        ex.Title AS ExperienceTitle,
        ex.StartDate AS ExperienceStartDate,
        ex.EndDate AS ExperienceEndDate,
        ex.Description AS ExperienceDescription,
        ed.InstitutionName AS EducationInstitution,
        ed.Degree AS EducationDegree,
        ed.StartDate AS EducationStartDate,
        ed.EndDate AS EducationEndDate,
        ed.Description AS EducationDescription
    FROM
        Resumes r
        JOIN Student s ON r.StudentId = s.UserId
        JOIN User u ON s.UserId = u.UUID
        LEFT JOIN ResumeSkill rs ON r.ResumeId = rs.ResumeId
        LEFT JOIN Skill sk ON rs.SkillId = sk.Id
        LEFT JOIN ResumeExperience re ON r.ResumeId = re.ResumeId
        LEFT JOIN Experience ex ON re.ExperienceId = ex.Id
        LEFT JOIN ResumeEducation reu ON r.ResumeId = reu.ResumeId
        LEFT JOIN Education ed ON reu.EducationId = ed.Id;
    ''')

    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)
    the_response = make_response(jsonify(list_of_resumes))
    the_response.status_code = 200
    return the_response


# POST /resumes
@resumes.route('/resumes', methods=['POST'])
def post_resume():
    # TODO: Implement
    return None


# GET /resumes/skills={x,y,...,z}
@resumes.route('/resumes/skills=<skills>', methods=['GET'])
def get_resumes_by_skills(skills):
    skills_list = skills.split(',')  # I think this is how you do it, don't trust me tho
    # TODO: Implement
    return None


# GET /resumes/company={x,y,...,z}
@resumes.route('/resumes/company=<companies>', methods=['GET'])
def get_resumes_by_company(companies):
    company_list = companies.split(',')
    # TODO: Implement
    return None


# GET /resumes/exclude_user_ids={id1,id2,...,id3}
@resumes.route('/resumes/exclude_user_ids=<exclude_ids>', methods=['GET'])
def get_resumes_excluding_user_ids(exclude_ids):
    exclude_ids_list = exclude_ids.split(',')
    # TODO: Implement
    return None


# GET /resumes/interview_at_company={company_id}
@resumes.route('/resumes/interview_at_company=<int:company_id>', methods=['GET'])
def get_resumes_by_interview_company_route(company_id):
    # TODO: Implement
    return None


# GET /resumes/degree_major={x}
@resumes.route('/resumes/degree_major=<degree_major>', methods=['GET'])
def get_resumes_by_degree_major(degree_major):
    # TODO: Implement
    return None


# GET /resumes/num_experiences={x}
@resumes.route('/resumes/num_experiences=<int:num_experiences>', methods=['GET'])
def get_resumes_by_num_experiences(num_experiences):
    # TODO: Implement
    return None


# GET /resumes/advisor_id={x}
@resumes.route('/resumes/advisor_id=<int:advisor_id>', methods=['GET'])
def get_resumes_by_advisor_id(advisor_id):
    # TODO: Implement
    return None


# GET /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['GET'])
def get_resume_by_id(resume_id):
    # TODO: Implement
    return None


# PUT /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['PUT'])
def update_resume(resume_id):
    # TODO: Implement
    return None


# DELETE /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['DELETE'])
def delete_resume(resume_id):
    # TODO: Implement
    return None





@resumes.route('/all_students', methods=['GET'])
def get_all_students():
    query = '''
        select s.UserId as id, R.Name 
        from ResumeDB.Student as s 
        join ResumeDB.Resumes R on s.UserId = R.StudentId
    '''

    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of products
    cursor.execute(query)

    # fetch all the data from the cursor
    # The cursor will return the data as a
    # Python Dictionary
    theData = cursor.fetchall()

    # Create a HTTP Response object and add results of the query to it
    # after "jasonify"-ing it.
    response = make_response(jsonify(theData))
    # set the proper HTTP Status code of 200 (meaning all good)
    response.status_code = 200
    # send the response back to the client
    return response
