
DROP DATABASE IF EXISTS ResumeDB;
CREATE DATABASE IF NOT EXISTS ResumeDB;
USE ResumeDB;

DROP TABLE IF EXISTS User;
CREATE TABLE IF NOT EXISTS User(
    DateCreated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastLogin DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE  CURRENT_TIMESTAMP,
    PhoneNumber VARCHAR(15),
    Name VARCHAR(100) NOT NULL,
    UUID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    Email VARCHAR(75) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    UserType INT NOT NULL,
    PRIMARY KEY (UUID)
);

 #Deletion in this table can only be done if there are no interviews OR recruiters OR resumes
 # instead of deletion, set isActive to false
DROP TABLE IF EXISTS Company;
CREATE TABLE IF NOT EXISTS Company(
    Id Int AUTO_INCREMENT NOT NULL,
    AcceptsInternational BOOLEAN,
    City VARCHAR(50),
    State VARCHAR(2),
    Country VARCHAR(50),
    Name  Varchar(100) NOT NULL ,
    isActive BOOLEAN DEFAULT True NOT NULL,
    DateCreated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE  CURRENT_TIMESTAMP,
    PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS SystemAdmin;
CREATE TABLE IF NOT EXISTS SystemAdmin(
    UserId BINARY(16) NOT NULL,
    PRIMARY KEY (UserId),
    FOREIGN KEY (UserId) REFERENCES User(UUID)
                                      ON UPDATE CASCADE
                                     ON DELETE CASCADE
);

DROP TABLE IF EXISTS CoopAdvisor;
CREATE TABLE IF NOT EXISTS CoopAdvisor(
    UserId BINARY(16) NOT NULL,
    PRIMARY KEY (UserId),
    FOREIGN KEY (UserId) REFERENCES User(UUID)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE
);

DROP TABLE IF EXISTS Recruiter;
CREATE TABLE IF NOT EXISTS Recruiter(
    UserId BINARY(16) NOT NULL,
    CompanyId INT NOT NULL,
    PRIMARY KEY (UserId),
    FOREIGN KEY (UserId) REFERENCES User(UUID)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE,
    Foreign Key (CompanyId) REFERENCES Company(Id)
                                    ON UPDATE CASCADE
                                    ON DELETE RESTRICT #We shouldn't delete companies unless they have no users.
);

DROP TABLE IF EXISTS Student;
CREATE TABLE IF NOT EXISTS Student(
    UserId BINARY(16) NOT NULL,
    GithubLink VARCHAR(100),
    LinkedInLink VARCHAR(100),
    University VARCHAR(100),
    GraduationYear YEAR,
    CurrentCity VARCHAR(50),
    CurrentState VARCHAR(2),
    AdvisorID BINARY(16),
    PRIMARY KEY (UserId),
    FOREIGN KEY (UserId) REFERENCES User(UUID)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE,
    FOREIGN KEY (AdvisorID) REFERENCES CoopAdvisor(UserId)
);

#In order to delete a resume you must delete the StudentResume, or the student
DROP TABLE IF EXISTS Resumes;
CREATE TABLE IF NOT EXISTS Resumes(
    ResumeId INT AUTO_INCREMENT NOT NULL,
    StudentId BINARY(16) NOT NULL,
    City VARCHAR(50),
    State VARCHAR(2),
    Country VARCHAR(50),
    Email VARCHAR(75),
    Name VARCHAR(100) NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    DateCreated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ResumeId),
    FOREIGN KEY (StudentId) REFERENCES Student(UserId)
                                  ON UPDATE CASCADE
                                  ON DELETE CASCADE
);

DROP TABLE IF EXISTS StudentResumes;
CREATE TABLE IF NOT EXISTS StudentResumes(
    StudentResumeId INT AUTO_INCREMENT NOT NULL,
    ResumeId INT NOT NULL,
    StudentId BINARY(16) NOT NULL,
    PRIMARY KEY (StudentResumeId),
    FOREIGN KEY (ResumeId) REFERENCES Resumes(ResumeId)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (StudentId) REFERENCES Student(UserId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

DROP TABLE If EXISTS Skill;
CREATE TABLE IF NOT EXISTS Skill(
    Id Int AUTO_INCREMENT NOT NULL,
    Name VARCHAR(50) NOT NULL ,
    Proficiency VARCHAR(30) NOT NULL,
    PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS ResumeSkill;
CREATE TABLE IF NOT EXISTS ResumeSkill(
    ResumeSkillId INT AUTO_INCREMENT NOT NULL,
    SkillId INT NOT NULL,
    ResumeId INT NOT NULL,
    PRIMARY KEY (ResumeSkillId),
    FOREIGN KEY (SkillId) REFERENCES Skill(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (ResumeId) REFERENCES Resumes(ResumeId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

DROP TABLE IF EXISTS Experience;
CREATE TABLE IF NOT EXISTS Experience(
    Id Int AUTO_INCREMENT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate Date,
    CompanyName VARCHAR(100) NOT NULL,
    Description VARCHAR(800),
    Title VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    State VARCHAR(2),
    PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS ResumeExperience;
CREATE TABLE IF NOT EXISTS ResumeExperience(
    ResumeExperienceId INT AUTO_INCREMENT NOT NULL,
    ExperienceId INT NOT NULL,
    ResumeId INT NOT NULL,
    PRIMARY KEY (ResumeExperienceId),
    FOREIGN KEY (ExperienceId) REFERENCES Experience(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (ResumeId) REFERENCES Resumes(ResumeId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

DROP TABLE IF EXISTS Education;
CREATE TABLE IF NOT EXISTS Education(
    Id Int AUTO_INCREMENT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate Date,
    InstitutionName VARCHAR(100) NOT NULL,
    Description VARCHAR(800),
    Degree VARCHAR(100) NOT NULL,
    PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS ResumeEducation;
CREATE TABLE IF NOT EXISTS ResumeEducation(
    ResumeEducationId INT AUTO_INCREMENT NOT NULL,
    EducationId INT NOT NULL,
    ResumeId INT NOT NULL,
    PRIMARY KEY (ResumeEducationId),
    FOREIGN KEY (EducationId) REFERENCES Education(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (ResumeId) REFERENCES Resumes(ResumeId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

DROP TABLE IF EXISTS ResumeCompany;
CREATE TABLE IF NOT EXISTS ResumeCompany(
    ResumeCompanyId INT AUTO_INCREMENT NOT NULL,
    CompanyId INT NOT NULL,
    ResumeId INT NOT NULL,
    PRIMARY KEY (ResumeCompanyId),
    FOREIGN KEY (CompanyId) REFERENCES Company(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (ResumeId) REFERENCES Resumes(ResumeId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

DROP TABLE IF EXISTS Interview;
CREATE TABLE IF NOT EXISTS Interview(
    Id INT AUTO_INCREMENT NOT NULL,
    CompanyId INT NOT NULL,
    StudentId BINARY(16) NOT NULL,
    InterviewDate DATE,
    PRIMARY KEY (Id),
    FOREIGN KEY (CompanyId) REFERENCES Company(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (StudentId) REFERENCES Student(UserId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);

-- Insert Users
INSERT INTO User (PhoneNumber, Name, Email, Status, UserType)
VALUES
   ('1234567890', 'John Doe', 'johndoe@example.com', 'Active', 1),
   ('0987654321', 'Jane Smith', 'janesmith@example.com', 'Active', 2),
   ('5551234567', 'Alice Johnson', 'alicej@example.com', 'Inactive', 3),
   ('9876543210', 'Bob Brown', 'bobb@example.com', 'Active', 1),
   ('1122334455', 'Charlie Green', 'charlieg@example.com', 'Inactive', 2),
   ('6677889900', 'Diana Prince', 'dianap@example.com', 'Active', 3);


-- Insert Companies
INSERT INTO Company (AcceptsInternational, City, State, Country, Name)
VALUES
   (TRUE, 'New York', 'NY', 'USA', 'TechCorp'),
   (FALSE, 'San Francisco', 'CA', 'USA', 'Innovatech'),
   (TRUE, 'Toronto', 'ON', 'Canada', 'MapleTech'),
   (TRUE, 'Seattle', 'WA', 'USA', 'CloudTech'),
   (FALSE, 'Austin', 'TX', 'USA', 'DevSolutions'),
   (TRUE, 'Vancouver', 'BC', 'Canada', 'NorthernCode');


-- Insert System Admins
INSERT INTO SystemAdmin (UserId)
SELECT UUID FROM User WHERE Email = 'johndoe@example.com';
INSERT INTO SystemAdmin (UserId)
SELECT UUID FROM User WHERE Email = 'bobb@example.com';


-- Insert Coop Advisors
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'janesmith@example.com';
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'charlieg@example.com';


-- Insert Recruiters
INSERT INTO Recruiter (UserId, CompanyId)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'alicej@example.com'), (SELECT Id FROM Company WHERE Name = 'TechCorp')),
   ((SELECT UUID FROM User WHERE Email = 'dianap@example.com'), (SELECT Id FROM Company WHERE Name = 'CloudTech')),
   ((SELECT UUID FROM User WHERE Email = 'bobb@example.com'), (SELECT Id FROM Company WHERE Name = 'NorthernCode'));


-- Insert Students
INSERT INTO Student (UserId, GithubLink, LinkedInLink, University, GraduationYear, CurrentCity, CurrentState, AdvisorID)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'johndoe@example.com'), 'https://github.com/johndoe', 'https://linkedin.com/in/johndoe', 'MIT', 2025, 'Cambridge', 'MA', NULL),
   ((SELECT UUID FROM User WHERE Email = 'bobb@example.com'), 'https://github.com/bobb', 'https://linkedin.com/in/bobb', 'Stanford', 2024, 'Palo Alto', 'CA', NULL),
   ((SELECT UUID FROM User WHERE Email = 'charlieg@example.com'), 'https://github.com/charlieg', 'https://linkedin.com/in/charlieg', 'Harvard', 2023, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'charlieg@example.com')));


-- Insert Resumes
INSERT INTO Resumes (StudentId, City, State, Country, Email, Name)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'johndoe@example.com'), 'Cambridge', 'MA', 'USA', 'johndoe@example.com', 'John Doe'),
   ((SELECT UUID FROM User WHERE Email = 'bobb@example.com'), 'Palo Alto', 'CA', 'USA', 'bobb@example.com', 'Bob Brown'),
   ((SELECT UUID FROM User WHERE Email = 'charlieg@example.com'), 'Boston', 'MA', 'USA', 'charlieg@example.com', 'Charlie Green');


-- Insert Skills
INSERT INTO Skill (Name, Proficiency)
VALUES
   ('Python', 'Expert'),
   ('SQL', 'Intermediate'),
   ('JavaScript', 'Beginner'),
   ('C++', 'Intermediate'),
   ('HTML', 'Beginner'),
   ('CSS', 'Beginner');


-- Insert Resume Skills
INSERT INTO ResumeSkill (SkillId, ResumeId)
VALUES
   ((SELECT Id FROM Skill WHERE Name = 'Python'), (SELECT ResumeId FROM Resumes WHERE Name = 'John Doe')),
   ((SELECT Id FROM Skill WHERE Name = 'C++'), (SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown')),
   ((SELECT Id FROM Skill WHERE Name = 'HTML'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Green'));


-- Insert Experience
INSERT INTO Experience (StartDate, EndDate, CompanyName, Description, Title, City, State)
VALUES
   ('2022-01-01', '2023-01-01', 'TechCorp', 'Worked on AI solutions.', 'Software Engineer', 'New York', 'NY'),
   ('2020-06-01', '2021-06-01', 'CloudTech', 'Developed cloud infrastructure.', 'Cloud Engineer', 'Seattle', 'WA'),
   ('2021-01-01', '2022-01-01', 'DevSolutions', 'Worked on full-stack development.', 'Software Developer', 'Austin', 'TX');


-- Insert Resume Experience
INSERT INTO ResumeExperience (ExperienceId, ResumeId)
VALUES
   ((SELECT Id FROM Experience WHERE Title = 'Software Engineer'), (SELECT ResumeId FROM Resumes WHERE Name = 'John Doe')),
   ((SELECT Id FROM Experience WHERE Title = 'Cloud Engineer'), (SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown')),
   ((SELECT Id FROM Experience WHERE Title = 'Software Developer'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Green'));


-- Insert Education
INSERT INTO Education (StartDate, EndDate, InstitutionName, Description, Degree)
VALUES
   ('2018-09-01', '2022-05-15', 'MIT', 'Studied Computer Science.', 'Bachelor of Science'),
   ('2016-09-01', '2020-05-15', 'Stanford', 'Studied Software Engineering.', 'Bachelor of Science'),
   ('2017-09-01', '2021-05-15', 'Harvard', 'Studied Data Science.', 'Bachelor of Science');


-- Insert Resume Education
INSERT INTO ResumeEducation (EducationId, ResumeId)
VALUES
   ((SELECT Id FROM Education WHERE InstitutionName = 'MIT'), (SELECT ResumeId FROM Resumes WHERE Name = 'John Doe')),
   ((SELECT Id FROM Education WHERE InstitutionName = 'Stanford'), (SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown')),
   ((SELECT Id FROM Education WHERE InstitutionName = 'Harvard'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Green'));


-- Insert Interviews
INSERT INTO Interview (CompanyId, StudentId, InterviewDate)
VALUES
   ((SELECT Id FROM Company WHERE Name = 'TechCorp'), (SELECT UUID FROM User WHERE Email = 'johndoe@example.com'), '2024-12-15'),
   ((SELECT Id FROM Company WHERE Name = 'CloudTech'), (SELECT UUID FROM User WHERE Email = 'bobb@example.com'), '2024-01-15'),
   ((SELECT Id FROM Company WHERE Name = 'DevSolutions'), (SELECT UUID FROM User WHERE Email = 'charlieg@example.com'), '2024-02-20');

-- Insert ResumeCompany
INSERT INTO ResumeCompany (CompanyId, ResumeId)
VALUES
    ((SELECT Id FROM Company WHERE Name = 'TechCorp'), (SELECT ResumeId FROM Resumes WHERE Name = 'John Doe')),
    ((SELECT Id FROM Company WHERE Name = 'CloudTech'), (SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown')),
    ((SELECT Id FROM Company WHERE Name = 'DevSolutions'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Green')),
    ((SELECT Id FROM Company WHERE Name = 'NorthernCode'), (SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown')),
    ((SELECT Id FROM Company WHERE Name = 'Innovatech'), (SELECT ResumeId FROM Resumes WHERE Name = 'John Doe'));

INSERT INTO StudentResumes (ResumeId, StudentId)
VALUES
    ((SELECT ResumeId FROM Resumes WHERE Name = 'John Doe'), (SELECT UUID FROM User WHERE Email = 'johndoe@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Bob Brown'), (SELECT UUID FROM User WHERE Email = 'bobb@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Green'), (SELECT UUID FROM User WHERE Email = 'charlieg@example.com'));
