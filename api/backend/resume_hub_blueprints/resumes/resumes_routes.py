from flask import current_app, request
from flask import Blueprint
from flask import jsonify
from flask import make_response
from backend.db_connection import db

resumes = Blueprint('resumes', __name__)


#  try curl -X GET "http://localhost:4000/r/test-resume" to see if its working
@resumes.route('/test-resume', methods=['GET'])
def test_resume_endpoint():
    return jsonify({"message": "Resume routes are working!"}), 200


# Make returned sql json friendly
def build_resumes_from_data(data):
    from collections import defaultdict

    resumes = defaultdict(lambda: {
        "ResumeID": None,
        "Name": None,
        "Email": None,
        "City": None,
        "State": None,
        "Country": None,
        "DateCreated": None,
        "LastUpdated": None,
        "GithubLink": None,
        "LinkedInLink": None,
        "University": None,
        "GraduationYear": None,
        "City": None,
        "State": None,
        "Skills": [],
        "Experience": [],
        "Education": [],
    })

    for row in data:
        resume_id = row["ResumeID"]

        resumes[resume_id].update({
            "ResumeID": resume_id,
            "Name": row["ResumeName"],
            "Email": row["ResumeEmail"],
            "City": row["ResumeCity"],
            "State": row["ResumeState"],
            "Country": row["ResumeCountry"],
            "DateCreated": row["ResumeDateCreated"],
            "LastUpdated": row["ResumeLastUpdated"],
            "GithubLink": row["StudentGithubLink"],
            "LinkedInLink": row["StudentLinkedInLink"],
            "University": row["StudentUniversity"],
            "GraduationYear": row["StudentGraduationYear"],
            "City": row["StudentCity"],
            "State": row["StudentState"],
        })

        if row.get("SkillName"):
            resumes[resume_id]["Skills"].append({
                "Name": row["SkillName"],
                "Proficiency": row["SkillProficiency"]
            })

        if row.get("ExperienceCompanyName"):
            resumes[resume_id]["Experience"].append({
                "CompanyName": row["ExperienceCompanyName"],
                "Title": row["ExperienceTitle"],
                "StartDate": row["ExperienceStartDate"],
                "EndDate": row["ExperienceEndDate"],
                "Description": row["ExperienceDescription"],
            })

        if row.get("EducationInstitution"):
            resumes[resume_id]["Education"].append({
                "Institution": row["EducationInstitution"],
                "Degree": row["EducationDegree"],
                "StartDate": row["EducationStartDate"],
                "EndDate": row["EducationEndDate"],
                "Description": row["EducationDescription"],
            })

    return list(resumes.values())

# Reusable query for most of what is needed for resumes. Is kind of chonk ¯\_(ツ)_/¯
def base_resume_query():
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
        s.UserId AS StudentUserId,
        s.GithubLink AS StudentGithubLink,
        s.LinkedInLink AS StudentLinkedInLink,
        s.University AS StudentUniversity,
        s.GraduationYear AS StudentGraduationYear,
        s.CurrentCity AS StudentCity,
        s.CurrentState AS StudentState,
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
    FROM Resumes r
    JOIN Student s ON r.StudentId = s.UserId
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
    query = base_resume_query()
    cursor = db.get_db().cursor()
    cursor.execute(query)
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200



# POST /resumes
@resumes.route('/resumes', methods=['POST'])
def post_resume():
    try:
        # parse post body
        data = request.get_json()
        student_id = data['StudentId']
        name = data['Name']
        email = data['Email']
        city = data['City']
        state = data['State']
        country = data['Country']
        skills = data.get('Skills', [])
        education = data.get('Education', [])
        experience = data.get('Experience', [])

        connection = db.get_db()
        cursor = connection.cursor()

        # Add to resumes main table
        cursor.execute('''
            INSERT INTO Resumes (StudentId, Name, Email, City, State, Country)
            VALUES (UNHEX(REPLACE(%s, '0x', '')), %s, %s, %s, %s, %s)
        ''', (student_id, name, email, city, state, country))

        resume_id = cursor.lastrowid

        # Insert into skills subtable
        for skill in skills:
            skill_name = skill['Name']
            skill_proficiency = skill['Proficiency']

            cursor.execute('SELECT Id FROM Skill WHERE Name = %s AND Proficiency = %s', (skill_name, skill_proficiency))
            skill_id_row = cursor.fetchone()

            if skill_id_row:
                skill_id = skill_id_row['Id']
            else:
                cursor.execute('INSERT INTO Skill (Name, Proficiency) VALUES (%s, %s)', (skill_name, skill_proficiency))
                skill_id = cursor.lastrowid

            # connect skill to resume
            cursor.execute('INSERT INTO ResumeSkill (SkillId, ResumeId) VALUES (%s, %s)', (skill_id, resume_id))

        # Insert into education subtable
        for edu in education:
            institution = edu['Institution']
            degree = edu['Degree']
            start_date = edu['StartDate']
            end_date = edu['EndDate']
            description = edu['Description']

            cursor.execute('''
                INSERT INTO Education (InstitutionName, Degree, StartDate, EndDate, Description)
                VALUES (%s, %s, %s, %s, %s)
            ''', (institution, degree, start_date, end_date, description))

            education_id = cursor.lastrowid

            # connect education to resume
            cursor.execute('INSERT INTO ResumeEducation (EducationId, ResumeId) VALUES (%s, %s)', (education_id, resume_id))

        # Insert into experience subtable
        for exp in experience:
            company_name = exp['CompanyName']
            title = exp['Title']
            start_date = exp['StartDate']
            end_date = exp.get('EndDate') 
            description = exp['Description']
            city = exp.get('City', None)
            state = exp.get('State', None)

            cursor.execute('''
                INSERT INTO Experience (CompanyName, Title, StartDate, EndDate, Description, City, State)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            ''', (company_name, title, start_date, end_date, description, city, state))

            experience_id = cursor.lastrowid

            # connect experience to resume
            cursor.execute('INSERT INTO ResumeExperience (ExperienceId, ResumeId) VALUES (%s, %s)', (experience_id, resume_id))

        connection.commit()

        return jsonify({"message": "Resume created successfully!"}), 201

    except Exception as e:
        current_app.logger.error(f"Error creating resume: {e}")
        return jsonify({"error": "An error has occured while creating resume"}), 500



# GET /resumes/skills={x,y,...,z}
@resumes.route('/resumes/skills=<skills>', methods=['GET'])
def get_resumes_by_skills(skills):
    skills_list = skills.split(',')
    placeholders = ','.join(['%s'] * len(skills_list))
    query = f"{base_resume_query()} WHERE sk.Name IN ({placeholders})"
    cursor = db.get_db().cursor()
    cursor.execute(query, skills_list)
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200



# GET /resumes/company={x,y,...,z}
@resumes.route('/resumes/company=<companies>', methods=['GET'])
def get_resumes_by_companies(companies):
    company_list = companies.split(',')
    placeholders = ','.join(['%s'] * len(company_list))

    query = f'''
    {base_resume_query()}
    JOIN ResumeCompany rc ON r.ResumeId = rc.ResumeId
    JOIN Company c ON rc.CompanyId = c.Id
    WHERE c.Name IN ({placeholders})
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query, company_list)

    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)

    return jsonify(resumes_json), 200


# GET /resumes/exclude_user_ids={id1,id2,...,id3}
@resumes.route('/resumes/exclude_user_ids=<exclude_ids>', methods=['GET'])
def get_resumes_exclude_user_ids(exclude_ids):
    binary_ids_list = [bytes.fromhex(id.lstrip('0x')) for id in exclude_ids.split(',')]
    placeholders = ','.join(['%s'] * len(binary_ids_list))
    query = f"{base_resume_query()} WHERE s.UserId NOT IN ({placeholders})"
    cursor = db.get_db().cursor()
    cursor.execute(query, binary_ids_list)
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200


# GET /resumes/interview_at_company={company_id}
@resumes.route('/resumes/interview_at_company=<int:company_id>', methods=['GET'])
def get_resumes_by_interview_company_route(company_id):
    query = f'''
    {base_resume_query()}
    JOIN Interview i ON r.StudentId = i.StudentId
    WHERE i.CompanyId = %s
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query, (company_id,))
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)

    return jsonify(resumes_json), 200


# GET /resumes/degree_major={x}
@resumes.route('/resumes/degree_major=<degree_major>', methods=['GET'])
def get_resumes_by_degree_major(degree_major):
    cursor = db.get_db().cursor()
    query = f'''
    {base_resume_query()}
    WHERE ed.Degree = %s
    '''
    cursor.execute(query, (degree_major,))
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200



# GET /resumes/num_experiences={x}
@resumes.route('/resumes/num_experiences=<int:num_experiences>', methods=['GET'])
def get_resumes_by_num_experiences(num_experiences):
    query = f'''
    {base_resume_query()}
    LEFT JOIN (
        SELECT re.ResumeId, COUNT(re.ExperienceId) AS ExperienceCount
        FROM ResumeExperience re
        GROUP BY re.ResumeId
    ) exp_count ON r.ResumeId = exp_count.ResumeId
    WHERE exp_count.ExperienceCount >= %s
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query, (num_experiences,))
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200


# GET /resumes/advisor_id={x}
@resumes.route('/resumes/advisor_id=<advisor_id>', methods=['GET'])
def get_resumes_by_advisor_id(advisor_id):
    cursor = db.get_db().cursor()

    query = f'''
    {base_resume_query()}
    WHERE LOWER(HEX(s.AdvisorID)) = LOWER(REPLACE(%s, '0x', ''))
    '''
    
    cursor.execute(query, (advisor_id,))
    data = cursor.fetchall()
    resumes_json = build_resumes_from_data(data)
    return jsonify(resumes_json), 200



# GET /resumes/{resume_id}
@resumes.route('/resumes/<int:resume_id>', methods=['GET'])
def get_resume_by_id(resume_id):
    cursor = db.get_db().cursor()

    query = f'''
    {base_resume_query()}
    WHERE r.ResumeId = %s
    '''
    
    cursor.execute(query, (resume_id,))
    data = cursor.fetchall()
    resume_json = build_resumes_from_data(data)
    return jsonify(resume_json), 200



# PUT /resumes/{resume_id}
@resumes.route('/resumes/<int:resume_id>', methods=['PUT'])
def update_resume(resume_id):
    try:
        payload = request.get_json()

        cursor = db.get_db().cursor()

        # Update the main resume table
        update_resume_query = '''
        UPDATE Resumes
        SET Name = %s, Email = %s, City = %s, State = %s, Country = %s
        WHERE ResumeId = %s
        '''
        cursor.execute(
            update_resume_query,
            ( payload.get("Name"), payload.get("Email"), payload.get("City"), payload.get("State"), payload.get("Country"), resume_id )
        )

        # update skills subtable
        if "Skills" in payload:
            delete_skills_query = '''
            DELETE FROM ResumeSkill WHERE ResumeId = %s
            '''
            cursor.execute(delete_skills_query, (resume_id,))

            # adding new skills 
            for skill in payload["Skills"]:
                skill_query = '''
                INSERT INTO Skill (Name, Proficiency)
                VALUES (%s, %s)
                ON DUPLICATE KEY UPDATE Proficiency = VALUES(Proficiency)
                '''
                cursor.execute(skill_query, (skill["Name"], skill["Proficiency"]))

                skill_id = cursor.lastrowid

                # connect to resume
                resume_skill_query = '''
                INSERT INTO ResumeSkill (SkillId, ResumeId)
                VALUES (%s, %s)
                '''
                cursor.execute(resume_skill_query, (skill_id, resume_id))

        # update education subtable
        if "Education" in payload:
            delete_education_query = '''
            DELETE FROM ResumeEducation WHERE ResumeId = %s
            '''
            cursor.execute(delete_education_query, (resume_id,))

            # new educationL
            for edu in payload["Education"]:
                edu_query = '''
                INSERT INTO Education (InstitutionName, Degree, StartDate, EndDate, Description)
                VALUES (%s, %s, %s, %s, %s)
                '''
                cursor.execute(edu_query, (edu["Institution"], edu["Degree"], edu["StartDate"], edu["EndDate"], edu["Description"]))

                education_id = cursor.lastrowid

                # connect to resume
                resume_education_query = '''
                INSERT INTO ResumeEducation (EducationId, ResumeId)
                VALUES (%s, %s)
                '''
                cursor.execute(resume_education_query, (education_id, resume_id))

        # update experience subtable
        if "Experience" in payload:
            delete_experience_query = '''
            DELETE FROM ResumeExperience WHERE ResumeId = %s
            '''
            cursor.execute(delete_experience_query, (resume_id,))

            # new experience:
            for exp in payload["Experience"]:
                exp_query = '''
                INSERT INTO Experience (CompanyName, Title, StartDate, EndDate, Description, City, State)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                '''
                cursor.execute(
                    exp_query,
                    ( exp["CompanyName"], exp["Title"], exp["StartDate"], exp["EndDate"], exp["Description"], exp["City"], exp["State"])
                )

                experience_id = cursor.lastrowid

                # connect to resume
                resume_experience_query = '''
                INSERT INTO ResumeExperience (ExperienceId, ResumeId)
                VALUES (%s, %s)
                '''
                cursor.execute(resume_experience_query, (experience_id, resume_id))

        db.get_db().commit()

        return jsonify({"message": "Resume updated successfully"}), 200

    except Exception as e:
        current_app.logger.error(f"Error updating resume: {e}")
        db.get_db().rollback()  # Rollback in case of error
        return jsonify({"error": "An error occurred while updating the resume"}), 500



# DELETE /resumes/{resume_id}
@resumes.route('/resumes/<int:resume_id>', methods=['DELETE'])
def delete_resume(resume_id):
    try:
        cursor = db.get_db().cursor()
        select_query = "SELECT ResumeId FROM Resumes WHERE ResumeId = %s"
        cursor.execute(select_query, (resume_id,))
        existing_resume = cursor.fetchone()

        if not existing_resume:
            return jsonify({"error": "Resume not found"}), 404

        delete_query = "DELETE FROM Resumes WHERE ResumeId = %s"
        cursor.execute(delete_query, (resume_id,))
        db.get_db().commit()

        return jsonify({"message": "Resume deleted successfully"}), 200

    except Exception as e:
        current_app.logger.error(f"Error deleting resume: {e}")
        return jsonify({"error": "An error occurred while deleting the resume"}), 500


# GET /resumes/all_students
@resumes.route('/all_students', methods=['GET'])
def get_all_students():
    json_list = []
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
    for data in theData:
        json_list.append({
            "Name": data['Name'],
            "Id": data['id'].hex(),
        })
    response = make_response(jsonify(json_list))
    # set the proper HTTP Status code of 200 (meaning all good)
    response.status_code = 200
    # send the response back to the client
    return response


@resumes.route('/resumes/user/<user_id>', methods=['GET'])
def get_by_user_id(user_id: str):
    cursor = db.get_db().cursor()
    # print(bytes(user_id.encode().hex()))
    print(str(bytes.fromhex(user_id)))
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
    print(query)
    cursor.execute(query)
    print(bytes.fromhex(user_id))

    the_data = cursor.fetchall()
    list_of_resumes = build_resumes_from_data(the_data)
    the_response = make_response(jsonify(list_of_resumes))
    the_response.status_code = 200
    return the_response
