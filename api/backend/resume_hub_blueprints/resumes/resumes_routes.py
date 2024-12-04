import uuid

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
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
                "City": row['ResumeCity'],
                "State": row['ResumeState'],
                "Skills": set(),  # Set to avoid dupes
                "Experience": set(),
                "Education": set()
            }

        if row['SkillName']:
            resumes_dict[resume_id]['Skills'].add(
                (row['SkillName'], row['SkillProficiency']))

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


def get_base_query():
    return '''
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
            LEFT JOIN Education ed ON reu.EducationId = ed.Id
    '''


# GET /resumes
@resumes.route('/resumes', methods=['GET'])
def get_resumes():
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)
    the_response = make_response(jsonify(list_of_resumes))
    the_response.status_code = 200
    return the_response


# Return true if the company exists
def company_exists_in_db(company_name):
    query = f"SELECT * FROM Company WHERE Name = '{company_name}'"
    cursor = db.get_db().cursor()
    cursor.execute(query)
    the_data = cursor.fetchall()
    if the_data:
        return True
    else:
        return False


# POST /resumes
@resumes.route('/resumes', methods=['POST'])
def post_resume():
    resume_info = request.json
    current_app.logger.info(resume_info)

    student_uuid = resume_info['StudentId']
    name = resume_info['Name']
    email = resume_info['Email']
    city = resume_info['City']
    state = resume_info['State']
    country = resume_info['Country']

    resumes_insert_query = f'''
        INSERT INTO Resumes (StudentId, City, State, Country, Email, Name)
        VALUES (UUID_TO_BIN('{student_uuid}'), '{city}',
                '{state}', '{country}', '{email}', '{name}');
    '''

    cursor = db.get_db().cursor()
    cursor.execute(resumes_insert_query)
    resume_id = cursor.lastrowid

    skills = resume_info.get('Skills', [])
    for skill in skills:
        skill_name = skill['Name']
        skill_proficiency = skill['Proficiency']

        cursor.execute('INSERT INTO Skill (Name, Proficiency) VALUES (%s, %s)',
                       (skill_name, skill_proficiency))
        skill_id = cursor.lastrowid

        # connect skill to resume
        cursor.execute(
            'INSERT INTO ResumeSkill (SkillId, ResumeId) VALUES (%s, %s)', (skill_id, resume_id))

    education = resume_info.get('Education', [])
    # Insert into education sub-table
    for edu in education:
        institution = edu['Institution']
        degree = edu['Degree']
        start_date = edu['StartDate']
        end_date = edu.get('EndDate', None)
        description = edu.get('Description', None)

        cursor.execute('''INSERT INTO Education (InstitutionName, Degree, StartDate, EndDate, Description) 
        VALUES (%s, %s, %s, %s, %s)''', (institution, degree, start_date, end_date, description))

        education_id = cursor.lastrowid

        # connect education to resume
        cursor.execute(
            'INSERT INTO ResumeEducation (EducationId, ResumeId) VALUES (%s, %s)', (education_id, resume_id))

    experience = resume_info.get('Experience', [])
    for exp in experience:
        company_name = exp['CompanyName']

        # Create company in database if does not exist
        if not company_exists_in_db(company_name):
            cursor.execute(
                f"INSERT INTO Company (Name) VALUES ('{company_name}')")

        # Resume company bridge table
        resume_company_bridge_table_query = f'''
            INSERT INTO ResumeCompany (CompanyId, ResumeId)
            VALUES ((SELECT Id FROM Company WHERE Name = '{company_name}'), {resume_id})
        '''
        cursor.execute(resume_company_bridge_table_query)

        title = exp['Title']
        start_date = exp['StartDate']
        end_date = exp.get('EndDate', None)
        description = exp.get('Description', None)
        city = exp.get('City', None)
        state = exp.get('State', None)

        cursor.execute('''
                    INSERT INTO Experience (CompanyName, Title, StartDate, EndDate, Description, City, State)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                ''', (company_name, title, start_date, end_date, description, city, state))

        experience_id = cursor.lastrowid

        # connect experience to resume
        cursor.execute('INSERT INTO ResumeExperience (ExperienceId, ResumeId) VALUES (%s, %s)',
                       (experience_id, resume_id))

    # StudentResumes bridge table
    student_resumes_bridge_table_query = f'''
        INSERT INTO StudentResumes(ResumeId, StudentId) VALUES ({resume_id}, UUID_TO_BIN('{student_uuid}'))
    '''
    cursor.execute(student_resumes_bridge_table_query)

    db.get_db().commit()
    response = make_response("Successfully added user")
    response.status_code = 200

    return response


# GET /resumes/skills={x,y,...,z}
@resumes.route('/resumes/skills=<skills>', methods=['GET'])
def get_resumes_by_skills(skills):
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    skills_list = skills.split(',')

    return_value = []
    already_added = []  # list of resume Ids already added
    for resume in list_of_resumes:
        for skill in resume["Skills"]:
            if skill["Name"].lower() in [item.lower() for item in skills_list]:
                if resume["ResumeID"] not in already_added:
                    return_value.append(resume)
                    already_added.append(resume["ResumeID"])

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/company={x,y,...,z}
@resumes.route('/resumes/company=<companies>', methods=['GET'])
def get_resumes_by_company(companies):
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    companies_list = companies.split(',')

    return_value = []
    already_added = []
    for resume in list_of_resumes:
        for experience in resume["Experience"]:
            if experience["CompanyName"].lower() in [item.lower() for item in companies_list]:
                if resume["ResumeID"] not in already_added:
                    return_value.append(resume)
                    already_added.append(resume["ResumeID"])

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/exclude_user_ids={id1,id2,...,id3}
@resumes.route('/resumes/exclude_user_ids=<exclude_ids>', methods=['GET'])
def get_resumes_excluding_user_ids(exclude_ids):
    # First, query to figure out which ResumeIds belong to "blocked" users.
    query = 'SELECT * FROM StudentResumes WHERE '
    exclude_id_list = exclude_ids.split(',')
    for x in range(len(exclude_id_list)):
        if x == len(exclude_id_list) - 1:
            query += f"StudentId = UUID_TO_BIN('{exclude_id_list[x]}')"
        else:
            query += f"StudentId = UUID_TO_BIN('{exclude_id_list[x]}') AND "

    cursor = db.get_db().cursor()
    cursor.execute(query)
    student_resumes_response = cursor.fetchall()

    resume_ids_to_avoid = []
    for row in student_resumes_response:
        resume_ids_to_avoid.append(row["ResumeId"])

    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)
    return_value = []
    for resume in list_of_resumes:
        if resume["ResumeID"] not in resume_ids_to_avoid:
            return_value.append(resume)

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/interview_at_company/{company_id}
@resumes.route('/resumes/interview_at_company/<int:company_id>', methods=['GET'])
def get_resumes_by_interview_company_route(company_id):
    # Get all resumes from users who got interviews at company id
    # get uuids of students with interviews there

    query = f"""SELECT BIN_TO_UUID(StudentId) as StudentId FROM Interview WHERE CompanyId = {
        company_id}"""

    cursor = db.get_db().cursor()
    cursor.execute(query)
    the_data = cursor.fetchall()

    students_who_got_interviews = []
    for row in the_data:
        student_id = row["StudentId"]
        students_who_got_interviews.append(student_id)

    student_resumes_query = f'''SELECT ResumeId FROM StudentResumes WHERE StudentId IN ('''
    for x in range(len(students_who_got_interviews)):
        student_uuid = students_who_got_interviews[x]

        if x == len(students_who_got_interviews) - 1:
            student_resumes_query += f"UUID_TO_BIN('{student_uuid}'))"
        else:
            student_resumes_query += f"UUID_TO_BIN('{student_uuid}'), "

    cursor.execute(student_resumes_query)
    student_resumes_response = cursor.fetchall()

    resume_id_list = []
    for row in student_resumes_response:
        resume_id = row["ResumeId"]
        resume_id_list.append(resume_id)

    cursor.execute(get_base_query())  # Get all resumes
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    return_value = []
    for resume in list_of_resumes:
        resume_id = resume["ResumeID"]
        if resume_id in resume_id_list:
            return_value.append(resume)

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/degree_major={x}
@resumes.route('/resumes/degree_major=<degree_major>', methods=['GET'])
def get_resumes_by_degree_major(degree_major):
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    return_value = []
    already_added = []
    for resume in list_of_resumes:
        for education in resume["Education"]:
            if degree_major.lower() in education["Degree"].lower() or degree_major.lower() in education["Description"].lower():
                if resume["ResumeID"] not in already_added:
                    return_value.append(resume)
                    already_added.append(resume["ResumeID"])

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/num_experiences={x}
@resumes.route('/resumes/num_experiences=<int:num_experiences>', methods=['GET'])
def get_resumes_by_num_experiences(num_experiences):
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query())
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    return_value = []
    already_added = []
    for resume in list_of_resumes:
        num_exp = len(resume["Experience"])
        if num_exp == num_experiences:
            if resume["ResumeID"] not in already_added:
                return_value.append(resume)
                already_added.append(resume["ResumeID"])

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/advisor_id/{x}
@resumes.route('/resumes/advisor_id/<advisor_uuid>', methods=['GET'])
def get_resumes_by_advisor_id(advisor_uuid):

    query = f"""
    SELECT ResumeId
    FROM StudentResumes
    WHERE StudentId IN (
        SELECT UserId
        FROM Student
        WHERE AdvisorID = UUID_TO_BIN('{advisor_uuid}')
    )
    """

    cursor = db.get_db().cursor()
    cursor.execute(query)
    the_data = cursor.fetchall()

    resume_ids = []
    for row in the_data:
        resume_ids.append(row["ResumeId"])

    cursor.execute(get_base_query())  # Get all resumes
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)

    return_value = []
    for resume in list_of_resumes:
        resume_id = resume["ResumeID"]
        if resume_id in resume_ids:
            return_value.append(resume)

    the_response = make_response(jsonify(return_value))
    the_response.status_code = 200
    return the_response


# GET /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['GET'])
def get_resume_by_id(resume_id):
    cursor = db.get_db().cursor()
    cursor.execute(get_base_query() + f" WHERE r.ResumeId = {resume_id}")
    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)
    the_response = make_response(jsonify(list_of_resumes))
    the_response.status_code = 200
    return the_response


# PUT /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['PUT'])
def update_resume(resume_id):
    resume_info = request.json
    current_app.logger.info(resume_info)

    name = resume_info['Name']
    email = resume_info['Email']
    city = resume_info['City']
    state = resume_info['State']
    country = resume_info['Country']

    resumes_update_query = f'''
        UPDATE Resumes
        SET
            City = '{city}',
            State = '{state}',
            Country = '{country}',
            Email = '{email}',
            Name = '{name}'
        WHERE ResumeId = {resume_id}
    '''

    cursor = db.get_db().cursor()
    cursor.execute(resumes_update_query)
    db.get_db().commit()

    response = make_response("Successfully updated resume")
    response.status_code = 200

    return response


# DELETE /resumes/{id}
@resumes.route('/resumes/<int:resume_id>', methods=['DELETE'])
def delete_resume(resume_id):
    query = f"DELETE FROM StudentResumes WHERE ResumeId = {resume_id};"
    query2 = f"DELETE FROM Resumes WHERE ResumeId = {resume_id};"
    cursor = db.get_db().cursor()
    cursor.execute(query)
    cursor.execute(query2)

    db.get_db().commit()
    response = make_response("Successfully deleted resume")
    response.status_code = 200

    return response


@resumes.route('/resumes/<user_id>', methods=['GET'])
def get_by_user_id(user_id: str):
    cursor = db.get_db().cursor()
    query = f'''
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
        LEFT JOIN Education ed ON reu.EducationId = ed.Id
    WHERE LOWER(HEX(s.UserId)) = '{user_id}';
    '''
    cursor.execute(query)

    the_data = cursor.fetchall()
    list_of_resumes = combine_multiple_rows_into_json_object(the_data)
    the_response = make_response(jsonify(list_of_resumes))
    the_response.status_code = 200
    return the_response

# Extra endpoint left over


@resumes.route('/resumes/all_students', methods=['GET'])
def get_all_students():
    query = '''
        select LOWER(HEX(s.UserId)) as id, R.Name 
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

    print(theData)
    # Create a HTTP Response object and add results of the query to it
    # after "jasonify"-ing it.
    response = make_response(jsonify(theData))
    # set the proper HTTP Status code of 200 (meaning all good)
    response.status_code = 200
    # send the response back to the client
    return response
