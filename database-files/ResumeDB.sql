
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
    PassedInterview BOOL DEFAULT FALSE,
    PRIMARY KEY (Id),
    FOREIGN KEY (CompanyId) REFERENCES Company(Id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
    FOREIGN KEY (StudentId) REFERENCES Student(UserId)
                                         ON UPDATE CASCADE
                                         ON DELETE CASCADE
);


-- Insert Users
-- UserType:
-- 1 is System Admin
-- 2 is Recruiter
-- 3 is Coop Advisor
-- 4 is Student
INSERT INTO User (PhoneNumber, Name, Email, Status, UserType)
VALUES
    # Admins
    ('1239671234', 'Leviticus Cornwall', 'admin@example.com', 'Active', 1),
    ('2342356321', 'John Admin', 'admin2@example.com', 'Active', 1),

    # Recruiters
    ('2125559876', 'Anna Bell', 'annabell@google.com', 'Active', 2),
    ('3135559876', 'Lucas Clark', 'lucasclark@apple.com', 'Inactive', 2),
    ('4155559876', 'Oliver Davis', 'oliverdavis@microsoft.com', 'Active', 2),
    ('5105559876', 'Sophia Evans', 'sophiaevans@salesforce.com', 'Active', 2),

    # Co-op advisors
    ('5123212144' 'Sam Miller', 'sam@aol.com', 'Active', 3)
    ('6195559876', 'James Foster', 'jamesfoster@example.com', 'Inactive', 3),
    ('7185559876', 'Isabella Green', 'isabellagreen@example.com', 'Active', 3),
    ('8185559876', 'Liam Harris', 'liamharris@example.com', 'Active', 3),
    ('9255559876', 'Mia Ibarra', 'miab@example.com', 'Inactive', 3),

    # Students
    ('4085559876', 'William Jackson', 'williamjackson@example.com', 'Active', 4),
    ('5305559876', 'Emily King', 'emilyking@example.com', 'Active', 4),
    ('6505559876', 'Benjamin Lee', 'benjaminlee@example.com', 'Inactive', 4),

    ('7075559876', 'Grace Mitchell', 'grace.mitchell@example.com', 'Active', 4),
    ('8185559876', 'Alexander Moore', 'alexmoore@example.com', 'Active', 4),
    ('9255559876', 'Charlotte Nelson', 'charlottenelson@example.com', 'Inactive', 4),

    ('8315559876', 'Henry O’Brien', 'henryo@example.com', 'Active', 4),
    ('6505559876', 'Scarlett Perez', 'scarlett.perez@example.com', 'Active', 4),
    ('5105559876', 'Jack Quinn', 'jackquinn@example.com', 'Inactive', 4),

    ('4155559876', 'Lily Roberts', 'lilyroberts@example.com', 'Active', 4),
    ('9165559876', 'David Scott', 'davidscott@example.com', 'Active', 4),
    ('4085559876', 'Zoey Taylor', 'zoeytaylor@example.com', 'Inactive', 4),

    ('8055559876', 'Ethan Underwood', 'ethanunderwood@example.com', 'Active', 4),
    ('8185559876', 'Aria Vargas', 'ariavargas@example.com', 'Active', 4),
    ('7321234567', 'Kyle Mitchell', 'kylemitchell@example.com', 'Active', 4);

-- Insert Companies
INSERT INTO Company (AcceptsInternational, City, State, Country, Name)
VALUES
    (TRUE, 'San Francisco', 'CA', 'USA', 'Salesforce'),
    (TRUE, 'Mountain View', 'CA', 'USA', 'Google'),
    (TRUE, 'Cupertino', 'CA', 'USA', 'Apple'),
    (TRUE, 'Redmond', 'WA', 'USA', 'Microsoft'),
    (TRUE, 'Austin', 'TX', 'USA', 'Dell Technologies'),
    (TRUE, 'New York', 'NY', 'USA', 'IBM'),
    (TRUE, 'Seattle', 'WA', 'USA', 'Amazon'),
    (TRUE, 'Menlo Park', 'CA', 'USA', 'Facebook'),
    (TRUE, 'Palo Alto', 'CA', 'USA', 'Tesla'),
    (TRUE, 'Chicago', 'IL', 'USA', 'McDonald\'s'),
    (TRUE, 'Los Altos', 'CA', 'USA', 'Netflix'),
    (TRUE, 'Los Angeles', 'CA', 'USA', 'Snap Inc.'),
    (TRUE, 'Boston', 'MA', 'USA', 'HubSpot'),
    (TRUE, 'Atlanta', 'GA', 'USA', 'Coca-Cola'),
    (TRUE, 'Portland', 'OR', 'USA', 'Nike'),
    (TRUE, 'San Jose', 'CA', 'USA', 'Cisco Systems'),
    (TRUE, 'London', 'EN', 'UK', 'BBC'),
    (TRUE, 'Berlin', 'BE', 'Germany', 'Siemens'),
    (TRUE, 'Toronto', 'ON', 'Canada', 'Shopify'),
    (TRUE, 'Sydney', 'NS', 'Australia', 'Atlassian'),
    (TRUE, 'Paris', 'ID', 'France', 'L’Oréal'),
    (TRUE, 'Stockholm', 'AB', 'Sweden', 'Spotify'),
    (TRUE, 'Bangalore', 'KA', 'India', 'Infosys'),
    (TRUE, 'Tokyo', 'JP', 'Japan', 'Sony'),
    (FALSE, 'Mexico City', 'MX', 'Mexico', 'Cemex'),
    (FALSE, 'Rio de Janeiro', 'RJ', 'Brazil', 'Petrobras'),
    (FALSE, 'Shanghai', 'SH', 'China', 'Alibaba'),
    (FALSE, 'Dubai', 'DU', 'UAE', 'Emirates Airline'),
    (FALSE, 'Singapore', 'SG', 'Singapore', 'Sea Group'),
    (FALSE, 'Vancouver', 'BC', 'Canada', 'Telus'),
    (FALSE, 'Zurich', 'ZH', 'Switzerland', 'Credit Suisse');

-- Insert System Admins
INSERT INTO SystemAdmin (UserId)
SELECT UUID FROM User WHERE Email = 'admin@example.com';
INSERT INTO SystemAdmin (UserId)
SELECT UUID FROM User WHERE Email = 'admin2@example.com';

-- Insert Recruiters
INSERT INTO Recruiter (UserId, CompanyId)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'annabell@google.com'), (SELECT Id FROM Company WHERE Name = 'Google')),
   ((SELECT UUID FROM User WHERE Email = 'lucasclark@apple.com'), (SELECT Id FROM Company WHERE Name = 'Apple')),
   ((SELECT UUID FROM User WHERE Email = 'oliverdavis@microsoft.com'), (SELECT Id FROM Company WHERE Name = 'Microsoft')),
   ((SELECT UUID FROM User WHERE Email = 'sophiaevans@salesforce.com'), (SELECT Id FROM Company WHERE Name = 'Salesforce'));

-- Insert Coop Advisors
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com';
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'isabellagreen@example.com';
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'liamharris@example.com';
INSERT INTO CoopAdvisor (UserId)
SELECT UUID FROM User WHERE Email = 'miab@example.com';

-- Insert Students
INSERT INTO Student (UserId, GithubLink, LinkedInLink, University, GraduationYear, CurrentCity, CurrentState, AdvisorID)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'williamjackson@example.com'), 'https://github.com/williamjackson', 'https://linkedin.com/in/williamjackson', 'Harvard University', 2024, 'Cambridge', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),
   ((SELECT UUID FROM User WHERE Email = 'emilyking@example.com'), 'https://github.com/emilyking', 'https://linkedin.com/in/emilyking', 'Stanford University', 2024, 'Palo Alto', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),
   ((SELECT UUID FROM User WHERE Email = 'benjaminlee@example.com'), 'https://github.com/benjaminlee', 'https://linkedin.com/in/benjaminlee', 'MIT', 2024, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),

   ((SELECT UUID FROM User WHERE Email = 'grace.mitchell@example.com'), 'https://github.com/gracemitchell', 'https://linkedin.com/in/gracemitchell', 'University of California, Berkeley', 2024, 'Berkeley', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'isabellagreen@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'alexmoore@example.com'), 'https://github.com/alexmoore', 'https://linkedin.com/in/alexmoore', 'Princeton University', 2024, 'Princeton', 'NJ', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'isabellagreen@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'charlottenelson@example.com'), 'https://github.com/charlottenelson', 'https://linkedin.com/in/charlottenelson', 'Yale University', 2024, 'New Haven', 'CT', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'isabellagreen@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'henryo@example.com'), 'https://github.com/henryobrien', 'https://linkedin.com/in/henryobrien', 'University of Chicago', 2024, 'Chicago', 'IL', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'scarlett.perez@example.com'), 'https://github.com/scarlettperez', 'https://linkedin.com/in/scarlettperez', 'Columbia University', 2024, 'New York', 'NY', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'jackquinn@example.com'), 'https://github.com/jackquinn', 'https://linkedin.com/in/jackquinn', 'Yale University', 2024, 'New Haven', 'CT', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'lilyroberts@example.com'), 'https://github.com/lilyroberts', 'https://linkedin.com/in/lilyroberts', 'University of Southern California', 2024, 'Los Angeles', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'davidscott@example.com'), 'https://github.com/davidscott', 'https://linkedin.com/in/davidscott', 'Harvard University', 2024, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'zoeytaylor@example.com'), 'https://github.com/zoeytaylor', 'https://linkedin.com/in/zoeytaylor', 'Stanford University', 2024, 'San Francisco', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), 'https://github.com/ethanunderwood', 'https://linkedin.com/in/ethanunderwood', 'Stanford University', 2024, 'San Francisco', 'CA', NULL),
   ((SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), 'https://github.com/ariavargas', 'https://linkedin.com/in/ariavargas', 'Northeastern University', 2025, 'Boston', 'MA', NULL),
   ((SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), 'https://github.com/kylemitchell', 'https://linkedin.com/in/kylemitchell', 'Northeastern University', 2025, 'Boston', 'MA', NULL);


-- Insert Resumes
INSERT INTO Resumes (StudentId, City, State, Country, Email, Name)
VALUES
   ((SELECT UUID FROM User WHERE Email = 'williamjackson@example.com'), 'Cambridge', 'MA', 'USA', 'williamjackson@example.com', 'William Jackson'),
   ((SELECT UUID FROM User WHERE Email = 'emilyking@example.com'), 'Palo Alto', 'CA', 'USA', 'emilyking@example.com', 'Emily King'),
   ((SELECT UUID FROM User WHERE Email = 'benjaminlee@example.com'), 'Boston', 'MA', 'USA', 'benjaminlee@example.com', 'Benjamin Lee'),
   ((SELECT UUID FROM User WHERE Email = 'grace.mitchell@example.com'), 'Berkeley', 'CA', 'USA', 'grace.mitchell@example.com', 'Grace Mitchell'),
   ((SELECT UUID FROM User WHERE Email = 'alexmoore@example.com'), 'Princeton', 'NJ', 'USA', 'alexmoore@example.com', 'Alexander Moore'),
   ((SELECT UUID FROM User WHERE Email = 'charlottenelson@example.com'), 'New Haven', 'CT', 'USA', 'charlottenelson@example.com', 'Charlotte Nelson'),
   ((SELECT UUID FROM User WHERE Email = 'henryo@example.com'), 'Chicago', 'IL', 'USA', 'henryo@example.com', 'Henry O’Brien'),
   ((SELECT UUID FROM User WHERE Email = 'scarlett.perez@example.com'), 'New York', 'NY', 'USA', 'scarlett.perez@example.com', 'Scarlett Perez'),
   ((SELECT UUID FROM User WHERE Email = 'jackquinn@example.com'), 'New Haven', 'CT', 'USA', 'jackquinn@example.com', 'Jack Quinn'),
   ((SELECT UUID FROM User WHERE Email = 'lilyroberts@example.com'), 'Los Angeles', 'CA', 'USA', 'lilyroberts@example.com', 'Lily Roberts'),
   ((SELECT UUID FROM User WHERE Email = 'davidscott@example.com'), 'Boston', 'MA', 'USA', 'davidscott@example.com', 'David Scott'),
   ((SELECT UUID FROM User WHERE Email = 'zoeytaylor@example.com'), 'San Francisco', 'CA', 'USA', 'zoeytaylor@example.com', 'Zoey Taylor'),
   ((SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), 'San Francisco', 'CA', 'USA', 'ethanunderwood@example.com', 'Ethan Underwood'),
   ((SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), 'Boston', 'MA', 'USA', 'ariavargas@example.com', 'Aria Vargas');

-- Insert Skills
INSERT INTO Skill (Name, Proficiency)
VALUES
   ('JavaScript', 'Expert'),
   ('Python', 'Intermediate'),
   ('SQL', 'Beginner'),
   ('React', 'Expert'),
   ('Node.js', 'Intermediate'),
   ('CSS', 'Expert'),
   ('Java', 'Beginner'),
   ('HTML', 'Expert'),
   ('Git', 'Intermediate'),
   ('Machine Learning', 'Intermediate'),
   ('Data Analysis', 'Expert'),
   ('Cloud Computing', 'Intermediate'),
   ('Docker', 'Beginner'),
   ('UI/UX Design', 'Expert'),
   ('Mobile Development', 'Intermediate'),
   ('Algorithms', 'Intermediate'),
   ('Cybersecurity', 'Beginner'),
   ('Public Speaking', 'Expert'),
   ('Leadership', 'Intermediate'),
   ('Problem Solving', 'Expert');

-- Insert Resume Skills
INSERT INTO ResumeSkill (SkillId, ResumeId)
VALUES
   ((SELECT Id FROM Skill WHERE Name = 'JavaScript'), (SELECT ResumeId FROM Resumes WHERE Email = 'williamjackson@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Python'), (SELECT ResumeId FROM Resumes WHERE Email = 'emilyking@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'SQL'), (SELECT ResumeId FROM Resumes WHERE Email = 'benjaminlee@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'React'), (SELECT ResumeId FROM Resumes WHERE Email = 'grace.mitchell@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Node.js'), (SELECT ResumeId FROM Resumes WHERE Email = 'alexmoore@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'CSS'), (SELECT ResumeId FROM Resumes WHERE Email = 'charlottenelson@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Java'), (SELECT ResumeId FROM Resumes WHERE Email = 'henryo@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'HTML'), (SELECT ResumeId FROM Resumes WHERE Email = 'scarlett.perez@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Git'), (SELECT ResumeId FROM Resumes WHERE Email = 'jackquinn@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Machine Learning'), (SELECT ResumeId FROM Resumes WHERE Email = 'lilyroberts@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Data Analysis'), (SELECT ResumeId FROM Resumes WHERE Email = 'davidscott@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Cloud Computing'), (SELECT ResumeId FROM Resumes WHERE Email = 'zoeytaylor@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Docker'), (SELECT ResumeId FROM Resumes WHERE Email = 'ethanunderwood@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'UI/UX Design'), (SELECT ResumeId FROM Resumes WHERE Email = 'ariavargas@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Mobile Development'), (SELECT ResumeId FROM Resumes WHERE Email = 'williamjackson@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Algorithms'), (SELECT ResumeId FROM Resumes WHERE Email = 'emilyking@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Cybersecurity'), (SELECT ResumeId FROM Resumes WHERE Email = 'benjaminlee@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Public Speaking'), (SELECT ResumeId FROM Resumes WHERE Email = 'grace.mitchell@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Leadership'), (SELECT ResumeId FROM Resumes WHERE Email = 'alexmoore@example.com')),
   ((SELECT Id FROM Skill WHERE Name = 'Problem Solving'), (SELECT ResumeId FROM Resumes WHERE Email = 'charlottenelson@example.com'));


-- Insert Experience
INSERT INTO Experience (StartDate, EndDate, CompanyName, Description, Title, City, State)
VALUES
   ('2022-06-01', '2023-05-31', 'Salesforce', 'Developed customer relationship management solutions for enterprises.', 'Software Engineer', 'San Francisco', 'CA'),
   ('2021-07-01', '2022-06-30', 'Google', 'Created machine learning models to optimize search algorithms.', 'Data Analyst', 'Mountain View', 'CA'),
   ('2023-01-01', '2024-11-30', 'Apple', 'Led the team in developing iOS applications with a focus on user experience.', 'Frontend Developer', 'Cupertino', 'CA'),
   ('2020-08-01', '2021-06-30', 'Microsoft', 'Worked on developing scalable cloud solutions for enterprise clients.', 'Cloud Engineer', 'Redmond', 'WA'),
   ('2022-09-01', '2023-12-31', 'Dell Technologies', 'Managed and improved the infrastructure of enterprise-level clients.', 'Infrastructure Engineer', 'Austin', 'TX'),
   ('2021-01-01', '2022-05-31', 'IBM', 'Worked on data-driven projects and AI-powered analytics platforms.', 'AI Engineer', 'New York', 'NY'),
   ('2023-04-01', '2024-11-30', 'Amazon', 'Developed AWS services and implemented cloud solutions for retail clients.', 'Software Engineer', 'Seattle', 'WA'),
   ('2020-05-01', '2021-08-31', 'Facebook', 'Developed features for the user-facing application on both web and mobile platforms.', 'Full Stack Developer', 'Menlo Park', 'CA'),
   ('2023-02-01', '2024-12-31', 'Tesla', 'Worked on autonomous vehicle software and connected vehicle systems.', 'Software Engineer', 'Palo Alto', 'CA'),
   ('2021-03-01', '2022-09-30', 'McDonald\'s', 'Designed marketing software tools to improve campaign results and customer engagement.', 'UI Developer', 'Chicago', 'IL'),
   ('2022-07-01', '2023-06-30', 'Snap Inc.', 'Led frontend team in building new user features for Snapchat.', 'Frontend Developer', 'Los Angeles', 'CA'),
   ('2023-06-01', '2024-06-01', 'HubSpot', 'Developed customer service solutions, integrated chatbots with CRM tools.', 'Software Engineer', 'Boston', 'MA'),
   ('2020-04-01', '2021-08-31', 'Coca-Cola', 'Designed marketing software tools to improve campaign results and customer engagement.', 'Marketing Technologist', 'Atlanta', 'GA'),
   ('2021-09-01', '2023-09-01', 'Nike', 'Developed mobile apps for fitness and sports equipment management.', 'Mobile App Developer', 'Portland', 'OR');


-- Insert Resume Experience
INSERT INTO ResumeExperience (ExperienceId, ResumeId)
VALUES
   ((SELECT Id FROM Experience WHERE Title = 'Software Engineer' AND CompanyName = 'Salesforce'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),
   ((SELECT Id FROM Experience WHERE Title = 'Data Analyst' AND CompanyName = 'Google'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),
   ((SELECT Id FROM Experience WHERE Title = 'Frontend Developer' AND CompanyName = 'Apple'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),

   ((SELECT Id FROM Experience WHERE Title = 'Cloud Engineer' AND CompanyName = 'Microsoft'), (SELECT ResumeId FROM Resumes WHERE Name = 'Grace Mitchell')),
   ((SELECT Id FROM Experience WHERE Title = 'Infrastructure Engineer' AND CompanyName = 'Dell Technologies'), (SELECT ResumeId FROM Resumes WHERE Name = 'Grace Mitchell')),

   ((SELECT Id FROM Experience WHERE Title = 'AI Engineer' AND CompanyName = 'IBM'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlotte Nelson')),
   ((SELECT Id FROM Experience WHERE Title = 'Software Engineer' AND CompanyName = 'Amazon'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlotte Nelson')),

   ((SELECT Id FROM Experience WHERE Title = 'Full Stack Developer' AND CompanyName = 'Facebook'), (SELECT ResumeId FROM Resumes WHERE Name = 'Scarlett Perez')),
   ((SELECT Id FROM Experience WHERE Title = 'Software Engineer' AND CompanyName = 'Tesla'), (SELECT ResumeId FROM Resumes WHERE Name = 'Jack Quinn')),
   ((SELECT Id FROM Experience WHERE Title = 'UI Developer' AND CompanyName = 'McDonald\'s'), (SELECT ResumeId FROM Resumes WHERE Name = 'Lily Roberts')),
   ((SELECT Id FROM Experience WHERE Title = 'Frontend Developer' AND CompanyName = 'Snap Inc.'), (SELECT ResumeId FROM Resumes WHERE Name = 'David Scott')),
   ((SELECT Id FROM Experience WHERE Title = 'Software Engineer' AND CompanyName = 'HubSpot'), (SELECT ResumeId FROM Resumes WHERE Name = 'Zoey Taylor')),
   ((SELECT Id FROM Experience WHERE Title = 'Marketing Technologist' AND CompanyName = 'Coca-Cola'), (SELECT ResumeId FROM Resumes WHERE Name = 'Ethan Underwood')),
   ((SELECT Id FROM Experience WHERE Title = 'Mobile App Developer' AND CompanyName = 'Nike'), (SELECT ResumeId FROM Resumes WHERE Name = 'Aria Vargas'));


-- Insert Education
INSERT INTO Education (StartDate, EndDate, InstitutionName, Description, Degree)
VALUES
   ('2020-09-01', '2024-05-15', 'Harvard University', 'Studied Computer Science with a focus on software engineering and AI.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Stanford University', 'Studied Software Engineering with a focus on algorithms and machine learning.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'MIT', 'Studied Computer Science, specializing in artificial intelligence and data science.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of California, Berkeley', 'Studied Computer Science with a focus on cloud computing and cybersecurity.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Princeton University', 'Studied Electrical Engineering and Computer Science.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Yale University', 'Studied Computer Science with a focus on network systems and data structures.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Chicago', 'Studied Data Science and Machine Learning.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Columbia University', 'Studied Software Engineering with a focus on AI and blockchain technology.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Southern California', 'Studied Computer Science with an emphasis on mobile app development.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Harvard University', 'Studied Data Science with an emphasis on statistical modeling and machine learning.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Stanford University', 'Studied Computer Science with a focus on software systems and AI.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Northeastern University', 'Studied Computer Science with a focus on cybersecurity and machine learning.', 'B.S. Computer Science');


-- Insert Resume Education
INSERT INTO ResumeEducation (EducationId, ResumeId)
VALUES
   (1, 1),
   (2, 2),
   (3, 3),
   (4, 4),
   (4, 4),
   (5, 5),
   (6, 6),
   (7, 7),
   (8, 8),
   (9, 9),
   (10, 10),
   (11, 11);


-- Insert Interviews
INSERT INTO Interview (CompanyId, StudentId, InterviewDate)
VALUES
   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'williamjackson@example.com'), '2024-12-15'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'williamjackson@example.com'), '2024-12-15'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'williamjackson@example.com'), '2024-12-15'),

   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'emilyking@example.com'), '2024-01-10'),
   ((SELECT Id FROM Company WHERE Name = 'Netflix'), (SELECT UUID FROM User WHERE Email = 'emilyking@example.com'), '2024-01-10'),
   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'emilyking@example.com'), '2024-01-10'),

   ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT UUID FROM User WHERE Email = 'benjaminlee@example.com'), '2024-02-05'),
   ((SELECT Id FROM Company WHERE Name = 'Netflix'), (SELECT UUID FROM User WHERE Email = 'grace.mitchell@example.com'), '2024-03-01'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'alexmoore@example.com'), '2024-03-15'),
   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'charlottenelson@example.com'), '2024-04-10'),
   ((SELECT Id FROM Company WHERE Name = 'Atlassian'), (SELECT UUID FROM User WHERE Email = 'henryo@example.com'), '2024-05-25'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'scarlett.perez@example.com'), '2024-06-15'),
   ((SELECT Id FROM Company WHERE Name = 'Tesla'), (SELECT UUID FROM User WHERE Email = 'lilyroberts@example.com'), '2024-07-20'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'davidscott@example.com'), '2024-08-05'),
   ((SELECT Id FROM Company WHERE Name = 'Telus'), (SELECT UUID FROM User WHERE Email = 'zoeytaylor@example.com'), '2024-09-10'),
   ((SELECT Id FROM Company WHERE Name = 'Shopify'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-10-15');


-- Insert ResumeCompany
INSERT INTO ResumeCompany (CompanyId, ResumeId)
VALUES
    ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),
    ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),
    ((SELECT Id FROM Company WHERE Name = 'Apple'), (SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson')),

    ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT ResumeId FROM Resumes WHERE Name = 'Grace Mitchell')),
    ((SELECT Id FROM Company WHERE Name = 'Dell Technologies'), (SELECT ResumeId FROM Resumes WHERE Name = 'Grace Mitchell')),

    ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlotte Nelson')),
    ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT ResumeId FROM Resumes WHERE Name = 'Charlotte Nelson')),

    ((SELECT Id FROM Company WHERE Name = 'Facebook'), (SELECT ResumeId FROM Resumes WHERE Name = 'Scarlett Perez')),
    ((SELECT Id FROM Company WHERE Name = 'Tesla'), (SELECT ResumeId FROM Resumes WHERE Name = 'Jack Quinn')),
    ((SELECT Id FROM Company WHERE Name = 'McDonald\'s'), (SELECT ResumeId FROM Resumes WHERE Name = 'Lily Roberts')),
    ((SELECT Id FROM Company WHERE Name = 'Snap Inc.'), (SELECT ResumeId FROM Resumes WHERE Name = 'David Scott')),
    ((SELECT Id FROM Company WHERE Name = 'HubSpot'), (SELECT ResumeId FROM Resumes WHERE Name = 'Zoey Taylor')),
    ((SELECT Id FROM Company WHERE Name = 'Coca-Cola'), (SELECT ResumeId FROM Resumes WHERE Name = 'Ethan Underwood')),
    ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT ResumeId FROM Resumes WHERE Name = 'Aria Vargas'));


INSERT INTO StudentResumes (ResumeId, StudentId)
VALUES
    ((SELECT ResumeId FROM Resumes WHERE Name = 'William Jackson'), (SELECT UUID FROM User WHERE Email = 'williamjackson@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Emily King'), (SELECT UUID FROM User WHERE Email = 'emilyking@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Benjamin Lee'), (SELECT UUID FROM User WHERE Email = 'benjaminlee@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Grace Mitchell'), (SELECT UUID FROM User WHERE Email = 'grace.mitchell@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Alexander Moore'), (SELECT UUID FROM User WHERE Email = 'alexmoore@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Charlotte Nelson'), (SELECT UUID FROM User WHERE Email = 'charlottenelson@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Henry O’Brien'), (SELECT UUID FROM User WHERE Email = 'henryo@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Scarlett Perez'), (SELECT UUID FROM User WHERE Email = 'scarlett.perez@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Jack Quinn'), (SELECT UUID FROM User WHERE Email = 'jackquinn@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Lily Roberts'), (SELECT UUID FROM User WHERE Email = 'lilyroberts@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'David Scott'), (SELECT UUID FROM User WHERE Email = 'davidscott@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Zoey Taylor'), (SELECT UUID FROM User WHERE Email = 'zoeytaylor@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Ethan Underwood'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Aria Vargas'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'));
