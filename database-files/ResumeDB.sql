
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
    ('2347623468', 'Anthony Adams', 'anthonyadams@netflix.com', 'Active', 2),

    # Co-op advisors
    ('6195559876', 'James Foster', 'jamesfoster@example.com', 'Inactive', 3),
    ('7185559876', 'Sam Miller', 'sam@aol.com', 'Active', 3),
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
    ('7321234567', 'Kyle Mitchell', 'kylemitchell@example.com', 'Active', 4),

    ('1238477822', 'Albert Ackley', 'albertackley@example.com', 'Active', 4),
    ('2746872028', 'Brian Beck', 'brianbeck@example.com', 'Active', 4),
    ('3904789872', 'Charlie Clouds', 'charlieclouds@example.com', 'Active', 4),
    ('4823747503', 'Daniel Downes', 'danieldownes@example.com', 'Active', 4),
    ('5982374982', 'Emilio Earhart', 'emilioearhart@example.com', 'Active', 4),
    ('6234786328', 'Frances Fisher', 'francesfisher@example.com', 'Active', 4),
    ('7234987239', 'Gregory Gill', 'gregorygill@example.com', 'Active', 4),
    ('8234768234', 'Harriett Hughes', 'harrietthughes@example.com', 'Active', 4),
    ('9897775542', 'Indiana Iglesias', 'indianaiglesias@example.com', 'Active', 4),
    ('1023867232', 'Jeremy Jones', 'jeremyjones@example.com', 'Active', 4),
    ('1134789325', 'Kevin King', 'kevinking@example.com', 'Active', 4),
    ('1234728920', 'Liam Lansing', 'liamlansing@example.com', 'Active', 4),
    ('1347832781', 'Monty Mills', 'montymills@example.com', 'Active', 4),
    ('1434567876', 'Nora Nathan', 'noranathan@example.com', 'Active', 4),
    ('1589728329', 'Oscar Ophelia', 'oscarophelia@example.com', 'Active', 4),
    ('1632498723', 'Pedro Pascal', 'pedropascal@example.com', 'Active', 4),
    ('1798763245', 'Quinn Quixote', 'quinnquixote@example.com', 'Active', 4),
    ('1896326345', 'Ryan Richards', 'ryanrichards@example.com', 'Active', 4),
    ('1923487782', 'Steven Seagull', 'stevenseagull@example.com', 'Active', 4),
    ('2047982313', 'Theodore Till', 'theodoretill@example.com', 'Active', 4),
    ('2196326345', 'Ulysses Unicorn', 'ulyssesunicorn@example.com', 'Active', 4),
    ('2298979847', 'Victor Vera', 'victorvera@example.com', 'Active', 4),
    ('2378786678', 'Wyatt Wings', 'wyattwings@example.com', 'Active', 4),
    ('2496326345', 'Xavier Xim', 'xavierxim@example.com', 'Active', 4),
    ('2598723479', 'Yennifer Young', 'yenniferyoung@example.com', 'Active', 4),
    ('2623948782', 'Zonda Zachary', 'zondazachary@example.com', 'Active', 4);


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
    (FALSE, 'Zurich', 'ZH', 'Switzerland', 'Credit Suisse'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Twitter'),
    (TRUE, 'Redmond', 'WA', 'USA', 'LinkedIn'),
    (TRUE, 'Seattle', 'WA', 'USA', 'Spotify USA'),
    (TRUE, 'Menlo Park', 'CA', 'USA', 'WhatsApp'),
    (TRUE, 'Austin', 'TX', 'USA', 'Rackspace Technology'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Square'),
    (TRUE, 'Los Angeles', 'CA', 'USA', 'Snapchat'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Uber'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Airbnb'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Pinterest'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Slack Technologies'),
    (TRUE, 'New York', 'NY', 'USA', 'Etsy'),
    (TRUE, 'Burlingame', 'CA', 'USA', 'Lyft'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Instacart'),
    (TRUE, 'Redwood City', 'CA', 'USA', 'Oracle'),
    (TRUE, 'Bentonville', 'AR', 'USA', 'Walmart Labs'),
    (TRUE, 'Austin', 'TX', 'USA', 'Dropbox'),
    (TRUE, 'Los Angeles', 'CA', 'USA', 'Dropbox'),
    (TRUE, 'Sunnyvale', 'CA', 'USA', 'Yahoo'),
    (TRUE, 'Chicago', 'IL', 'USA', 'GoDaddy'),
    (TRUE, 'San Francisco', 'CA', 'USA', 'Palantir Technologies'),
    (TRUE, 'Chicago', 'IL', 'USA', 'Grubhub'),
    (TRUE, 'Dallas', 'TX', 'USA', 'Texas Instruments'),
    (TRUE, 'Cambridge', 'MA', 'USA', 'HubSpot'),
    (TRUE, 'Atlanta', 'GA', 'USA', 'Mailchimp'),
    (TRUE, 'Palo Alto', 'CA', 'USA', 'VMware'),
    (TRUE, 'Reston', 'VA', 'USA', 'Leidos');


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
SELECT UUID FROM User WHERE Email = 'sam@aol.com';
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

   ((SELECT UUID FROM User WHERE Email = 'grace.mitchell@example.com'), 'https://github.com/gracemitchell', 'https://linkedin.com/in/gracemitchell', 'University of California, Berkeley', 2024, 'Berkeley', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),
   ((SELECT UUID FROM User WHERE Email = 'alexmoore@example.com'), 'https://github.com/alexmoore', 'https://linkedin.com/in/alexmoore', 'Princeton University', 2024, 'Princeton', 'NJ', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),
   ((SELECT UUID FROM User WHERE Email = 'charlottenelson@example.com'), 'https://github.com/charlottenelson', 'https://linkedin.com/in/charlottenelson', 'Yale University', 2024, 'New Haven', 'CT', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'sam@aol.com'))),

   ((SELECT UUID FROM User WHERE Email = 'henryo@example.com'), 'https://github.com/henryobrien', 'https://linkedin.com/in/henryobrien', 'University of Chicago', 2024, 'Chicago', 'IL', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'scarlett.perez@example.com'), 'https://github.com/scarlettperez', 'https://linkedin.com/in/scarlettperez', 'Columbia University', 2024, 'New York', 'NY', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'jackquinn@example.com'), 'https://github.com/jackquinn', 'https://linkedin.com/in/jackquinn', 'Yale University', 2024, 'New Haven', 'CT', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'liamharris@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'lilyroberts@example.com'), 'https://github.com/lilyroberts', 'https://linkedin.com/in/lilyroberts', 'University of Southern California', 2024, 'Los Angeles', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'davidscott@example.com'), 'https://github.com/davidscott', 'https://linkedin.com/in/davidscott', 'Harvard University', 2024, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'zoeytaylor@example.com'), 'https://github.com/zoeytaylor', 'https://linkedin.com/in/zoeytaylor', 'Stanford University', 2024, 'San Francisco', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'miab@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), 'https://github.com/ethanunderwood', 'https://linkedin.com/in/ethanunderwood', 'Stanford University', 2024, 'San Francisco', 'CA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), 'https://github.com/ariavargas', 'https://linkedin.com/in/ariavargas', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), 'https://github.com/kylemitchell', 'https://linkedin.com/in/kylemitchell', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'albertackley@example.com'), 'https://github.com/albertackley', 'https://linkedin.com/in/albertackley', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'brianbeck@example.com'), 'https://github.com/brianbeck', 'https://linkedin.com/in/brianbeck', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'charlieclouds@example.com'), 'https://github.com/charlieclouds', 'https://linkedin.com/in/charlieclouds', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'danieldownes@example.com'), 'https://github.com/danieldownes', 'https://linkedin.com/in/danieldownes', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), 'https://github.com/emilioearhart', 'https://linkedin.com/in/emilioearhart', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), 'https://github.com/francesfisher', 'https://linkedin.com/in/francesfisher', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), 'https://github.com/gregorygill', 'https://linkedin.com/in/gregorygill', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'harrietthughes@example.com'), 'https://github.com/harrietthughes', 'https://linkedin.com/in/harrietthughes', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'indianaiglesias@example.com'), 'https://github.com/indianaiglesias', 'https://linkedin.com/in/indianaiglesias', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'jeremyjones@example.com'), 'https://github.com/jeremyjones', 'https://linkedin.com/in/jeremyjones', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'kevinking@example.com'), 'https://github.com/kevinking', 'https://linkedin.com/in/kevinking', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'liamlansing@example.com'), 'https://github.com/liamlansing', 'https://linkedin.com/in/liamlansing', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'montymills@example.com'), 'https://github.com/montymills', 'https://linkedin.com/in/montymills', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'noranathan@example.com'), 'https://github.com/noranathan', 'https://linkedin.com/in/noranathan', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'oscarophelia@example.com'), 'https://github.com/oscarophelia', 'https://linkedin.com/in/oscarophelia', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'pedropascal@example.com'), 'https://github.com/pedropascal', 'https://linkedin.com/in/pedropascal', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'quinnquixote@example.com'), 'https://github.com/quinnquixote', 'https://linkedin.com/in/quinnquixote', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'ryanrichards@example.com'), 'https://github.com/ryanrichards', 'https://linkedin.com/in/ryanrichards', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'stevenseagull@example.com'), 'https://github.com/stevenseagull', 'https://linkedin.com/in/stevenseagull', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'theodoretill@example.com'), 'https://github.com/theodoretill', 'https://linkedin.com/in/theodoretill', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'ulyssesunicorn@example.com'), 'https://github.com/ulyssesunicorn', 'https://linkedin.com/in/ulyssesunicorn', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'victorvera@example.com'), 'https://github.com/victorvera', 'https://linkedin.com/in/victorvera', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'wyattwings@example.com'), 'https://github.com/wyattwings', 'https://linkedin.com/in/wyattwings', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'xavierxim@example.com'), 'https://github.com/xavierxim', 'https://linkedin.com/in/xavierxim', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),
   ((SELECT UUID FROM User WHERE Email = 'yenniferyoung@example.com'), 'https://github.com/yenniferyoung', 'https://linkedin.com/in/yenniferyoung', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com'))),

   ((SELECT UUID FROM User WHERE Email = 'zondazachary@example.com'), 'https://github.com/zondazachary', 'https://linkedin.com/in/zondazachary', 'Northeastern University', 2025, 'Boston', 'MA', (SELECT UserId FROM CoopAdvisor WHERE UserId = (SELECT UUID FROM User WHERE Email = 'jamesfoster@example.com')));


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
   ((SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), 'Boston', 'MA', 'USA', 'ariavargas@example.com', 'Aria Vargas'),

   ((SELECT UUID FROM User WHERE Email = 'albertackley@example.com'), 'Boston', 'MA', 'USA', 'albertackley@example.com', 'Albert Ackley'),
   ((SELECT UUID FROM User WHERE Email = 'brianbeck@example.com'), 'Cambridge', 'MA', 'USA', 'brianbeck@example.com', 'Brian Beck'),
   ((SELECT UUID FROM User WHERE Email = 'charlieclouds@example.com'), 'Providence', 'RI', 'USA', 'charlieclouds@example.com', 'Charlie Clouds'),
   ((SELECT UUID FROM User WHERE Email = 'danieldownes@example.com'), 'New Haven', 'CT', 'USA', 'danieldownes@example.com', 'Daniel Downes'),
   ((SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), 'Hartford', 'CT', 'USA', 'emilioearhart@example.com', 'Emilio Earhart'),
   ((SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), 'Burlington', 'VT', 'USA', 'francesfisher@example.com', 'Frances Fisher'),
   ((SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), 'Portland', 'ME', 'USA', 'gregorygill@example.com', 'Gregory Gill'),
   ((SELECT UUID FROM User WHERE Email = 'harrietthughes@example.com'), 'Manchester', 'NH', 'USA', 'harrietthughes@example.com', 'Harriett Hughes'),
   ((SELECT UUID FROM User WHERE Email = 'indianaiglesias@example.com'), 'Albany', 'NY', 'USA', 'indianaiglesias@example.com', 'Indiana Iglesias'),
   ((SELECT UUID FROM User WHERE Email = 'jeremyjones@example.com'), 'Philadelphia', 'PA', 'USA', 'jeremyjones@example.com', 'Jeremy Jones'),
   ((SELECT UUID FROM User WHERE Email = 'kevinking@example.com'), 'Pittsburgh', 'PA', 'USA', 'kevinking@example.com', 'Kevin King'),
   ((SELECT UUID FROM User WHERE Email = 'liamlansing@example.com'), 'Baltimore', 'MD', 'USA', 'liamlansing@example.com', 'Liam Lansing'),
   ((SELECT UUID FROM User WHERE Email = 'montymills@example.com'), 'Washington', 'DC', 'USA', 'montymills@example.com', 'Monty Mills'),
   ((SELECT UUID FROM User WHERE Email = 'noranathan@example.com'), 'Richmond', 'VA', 'USA', 'noranathan@example.com', 'Nora Nathan'),
   ((SELECT UUID FROM User WHERE Email = 'oscarophelia@example.com'), 'Charlotte', 'NC', 'USA', 'oscarophelia@example.com', 'Oscar Ophelia'),
   ((SELECT UUID FROM User WHERE Email = 'pedropascal@example.com'), 'Atlanta', 'GA', 'USA', 'pedropascal@example.com', 'Pedro Pascal'),
   ((SELECT UUID FROM User WHERE Email = 'quinnquixote@example.com'), 'Orlando', 'FL', 'USA', 'quinnquixote@example.com', 'Quinn Quixote'),
   ((SELECT UUID FROM User WHERE Email = 'ryanrichards@example.com'), 'Miami', 'FL', 'USA', 'ryanrichards@example.com', 'Ryan Richards'),
   ((SELECT UUID FROM User WHERE Email = 'stevenseagull@example.com'), 'Birmingham', 'AL', 'USA', 'stevenseagull@example.com', 'Steven Seagull'),
   ((SELECT UUID FROM User WHERE Email = 'theodoretill@example.com'), 'Nashville', 'TN', 'USA', 'theodoretill@example.com', 'Theodore Till'),
   ((SELECT UUID FROM User WHERE Email = 'ulyssesunicorn@example.com'), 'Louisville', 'KY', 'USA', 'ulyssesunicorn@example.com', 'Ulysses Unicorn'),
   ((SELECT UUID FROM User WHERE Email = 'victorvera@example.com'), 'Indianapolis', 'IN', 'USA', 'victorvera@example.com', 'Victor Vera'),
   ((SELECT UUID FROM User WHERE Email = 'wyattwings@example.com'), 'Chicago', 'IL', 'USA', 'wyattwings@example.com', 'Wyatt Wings'),
   ((SELECT UUID FROM User WHERE Email = 'xavierxim@example.com'), 'St. Louis', 'MO', 'USA', 'xavierxim@example.com', 'Xavier Xim'),
   ((SELECT UUID FROM User WHERE Email = 'yenniferyoung@example.com'), 'Minneapolis', 'MN', 'USA', 'yenniferyoung@example.com', 'Yennifer Young'),
   ((SELECT UUID FROM User WHERE Email = 'zondazachary@example.com'), 'Milwaukee', 'WI', 'USA', 'zondazachary@example.com', 'Zonda Zachary');


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
   ('Problem Solving', 'Expert'),
   ('Python', 'Intermediate'),
   ('HTML', 'Beginner'),
   ('Django', 'Expert'),
   ('JavaScript', 'Beginner'),
   ('SQL', 'Expert'),
   ('Node.js', 'Intermediate'),
   ('C++', 'Beginner'),
   ('React', 'Expert'),
   ('Go', 'Intermediate'),
   ('Flask', 'Beginner'),
   ('Angular', 'Intermediate'),
   ('TensorFlow', 'Expert'),
   ('PHP', 'Expert'),
   ('Vue.js', 'Beginner'),
   ('Keras', 'Intermediate'),
   ('Python', 'Beginner'),
   ('Rust', 'Expert'),
   ('Bash/Shell', 'Intermediate'),
   ('Pandas', 'Expert'),
   ('Java', 'Beginner'),
   ('C#', 'Expert'),
   ('React', 'Beginner'),
   ('Matplotlib', 'Intermediate'),
   ('SQL', 'Beginner'),
   ('Swift', 'Intermediate'),
   ('NumPy', 'Beginner'),
   ('CSS', 'Expert'),
   ('Express.js', 'Expert'),
   ('Node.js', 'Beginner'),
   ('Java', 'Expert'),
   ('JavaScript', 'Expert'),
   ('Angular', 'Beginner'),
   ('Vue.js', 'Expert'),
   ('Rust', 'Intermediate'),
   ('Pandas', 'Beginner'),
   ('Bash/Shell', 'Beginner'),
   ('C++', 'Expert'),
   ('PHP', 'Intermediate'),
   ('HTML', 'Intermediate'),
   ('Flask', 'Expert'),
   ('Go', 'Beginner'),
   ('JavaScript', 'Intermediate'),
   ('Scikit-learn', 'Expert'),
   ('Python', 'Expert'),
   ('TensorFlow', 'Beginner'),
   ('React', 'Intermediate'),
   ('Django', 'Beginner'),
   ('CSS', 'Intermediate'),
   ('Swift', 'Beginner'),
   ('SQL', 'Intermediate'),
   ('Keras', 'Expert'),
   ('NumPy', 'Expert'),
   ('Angular', 'Expert'),
   ('Rust', 'Beginner'),
   ('Java', 'Intermediate'),
   ('Express.js', 'Beginner'),
   ('C#', 'Intermediate'),
   ('Bash/Shell', 'Expert'),
   ('Flask', 'Intermediate'),
   ('Scikit-learn', 'Beginner'),
   ('PHP', 'Beginner'),
   ('HTML', 'Expert'),
   ('Pandas', 'Intermediate'),
   ('Matplotlib', 'Beginner'),
   ('C++', 'Intermediate'),
   ('NumPy', 'Intermediate'),
   ('CSS', 'Beginner'),
   ('Swift', 'Expert'),
   ('Go', 'Expert'),
   ('Node.js', 'Expert'),
   ('Scikit-learn', 'Intermediate'),
   ('JavaScript', 'Intermediate'),
   ('TypeScript', 'Intermediate'),
   ('Kotlin', 'Beginner'),
   ('Docker', 'Expert'),
   ('Kubernetes', 'Intermediate'),
   ('AWS', 'Expert'),
   ('Linux', 'Beginner'),
   ('PostgreSQL', 'Intermediate'),
   ('MongoDB', 'Expert'),
   ('Redis', 'Intermediate'),
   ('GraphQL', 'Beginner'),
   ('Elasticsearch', 'Expert'),
   ('Hadoop', 'Beginner'),
   ('Spark', 'Expert'),
   ('Scala', 'Intermediate'),
   ('MATLAB', 'Beginner'),
   ('Tableau', 'Intermediate'),
   ('Power BI', 'Expert'),
   ('Firebase', 'Intermediate'),
   ('Figma', 'Expert'),
   ('Adobe XD', 'Intermediate'),
   ('Bootstrap', 'Beginner'),
   ('Tailwind CSS', 'Expert'),
   ('Unity', 'Intermediate'),
   ('Unreal Engine', 'Beginner'),
   ('GameMaker', 'Expert'),
   ('Blender', 'Intermediate'),
   ('3ds Max', 'Beginner');


-- Insert Resume Skills
INSERT INTO ResumeSkill (SkillId, ResumeId)
VALUES
   (1, 1),
   (2, 1),
   (3, 1),
   (4, 2),
   (5, 2),
   (6, 2),
   (7, 3),
   (8, 3),
   (9, 3),
   (10, 4),
   (11, 4),
   (12, 4),
   (13, 5),
   (14, 5),
   (15, 5),
   (16, 6),
   (17, 6),
   (18, 6),
   (19, 7),
   (20, 7),
   (21, 7),
   (22, 8),
   (23, 8),
   (24, 8),
   (25, 9),
   (26, 9),
   (27, 9),
   (28, 10),
   (29, 10),
   (30, 10),
   (31, 11),
   (32, 11),
   (33, 11),
   (34, 12),
   (35, 12),
   (36, 12),
   (37, 13),
   (38, 13),
   (39, 13),
   (40, 14),
   (41, 14),
   (42, 14),
   (43, 15),
   (44, 15),
   (45, 15),
   (46, 16),
   (47, 16),
   (48, 16),
   (49, 17),
   (50, 17),
   (51, 17),
   (52, 18),
   (53, 18),
   (54, 18),
   (55, 19),
   (56, 19),
   (57, 19),
   (58, 20),
   (59, 20),
   (60, 20),
   (61, 21),
   (62, 21),
   (63, 21),
   (64, 22),
   (65, 22),
   (66, 22),
   (67, 23),
   (68, 23),
   (69, 23),
   (70, 24),
   (71, 24),
   (72, 24),
   (73, 25),
   (74, 25),
   (75, 25),
   (76, 26),
   (77, 26),
   (78, 26),
   (79, 27),
   (80, 27),
   (81, 27),
   (82, 28),
   (83, 28),
   (84, 28),
   (85, 29),
   (86, 29),
   (87, 29),
   (88, 30),
   (89, 30),
   (90, 30),
   (91, 31),
   (92, 31),
   (93, 31),
   (94, 32),
   (95, 32),
   (96, 32),
   (97, 33),
   (98, 33),
   (99, 33),
   (100, 34),
   (101, 34),
   (102, 34),
   (103, 35),
   (104, 35),
   (105, 35),
   (106, 36),
   (107, 36),
   (108, 36),
   (109, 37),
   (110, 37),
   (111, 37),
   (112, 38),
   (113, 38),
   (114, 38),
   (115, 39),
   (116, 39),
   (117, 39),
   (118, 40),
   (119, 40);


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
   ('2021-09-01', '2023-09-01', 'Nike', 'Developed mobile apps for fitness and sports equipment management.', 'Mobile App Developer', 'Portland', 'OR'),

   ('2022-03-01', '2023-02-28', 'Oracle', 'Implemented database solutions for enterprise resource planning.', 'Database Developer', 'Redwood City', 'CA'),
   ('2020-07-01', '2021-07-01', 'Adobe', 'Created tools for photo editing and graphic design.', 'Software Developer', 'San Jose', 'CA'),
   ('2021-05-01', '2022-08-31', 'LinkedIn', 'Enhanced algorithms for job recommendations and networking.', 'Data Engineer', 'Sunnyvale', 'CA'),
   ('2023-01-01', '2024-12-31', 'Twitter', 'Developed scalable backend services for real-time user interaction.', 'Backend Engineer', 'San Francisco', 'CA'),
   ('2020-02-01', '2021-05-31', 'Uber', 'Built real-time navigation and routing features for drivers.', 'Software Engineer', 'San Francisco', 'CA'),
   ('2022-06-01', '2023-06-30', 'Slack', 'Developed integrations and automation tools for workplace communication.', 'Integration Engineer', 'Denver', 'CO'),
   ('2023-01-01', '2024-12-31', 'Stripe', 'Designed APIs for payment processing and fraud detection.', 'Software Engineer', 'Seattle', 'WA'),
   ('2021-04-01', '2022-04-30', 'Spotify', 'Enhanced user experience by implementing personalized playlists.', 'UI/UX Developer', 'New York', 'NY'),
   ('2020-09-01', '2021-09-30', 'Etsy', 'Built ecommerce features to improve customer buying experiences.', 'Full Stack Engineer', 'Brooklyn', 'NY'),
   ('2022-08-01', '2023-09-30', 'Intel', 'Developed software solutions for chip performance optimization.', 'Embedded Systems Engineer', 'Santa Clara', 'CA'),
   ('2023-03-01', '2024-11-30', 'Samsung', 'Worked on Android applications for Samsung devices.', 'Android Developer', 'Plano', 'TX'),
   ('2021-11-01', '2022-12-31', 'Dropbox', 'Developed features for cloud storage solutions.', 'Software Engineer', 'San Francisco', 'CA'),
   ('2020-06-01', '2021-07-31', 'Airbnb', 'Designed user interfaces for vacation rental applications.', 'Frontend Engineer', 'San Francisco', 'CA'),
   ('2023-07-01', '2024-12-31', 'Zoom', 'Improved video conferencing tools and virtual collaboration solutions.', 'Video Software Engineer', 'San Jose', 'CA'),
   ('2021-02-01', '2022-05-31', 'WeWork', 'Implemented building access systems using IoT solutions.', 'IoT Engineer', 'New York', 'NY'),
   ('2022-01-01', '2023-02-28', 'Twitch', 'Built streaming analytics tools for content creators.', 'Software Engineer', 'Seattle', 'WA'),
   ('2023-04-01', '2024-11-30', 'Lyft', 'Enhanced ride-matching algorithms to optimize routes.', 'Machine Learning Engineer', 'San Francisco', 'CA'),
   ('2020-08-01', '2021-11-30', 'General Motors', 'Developed software for electric vehicle power management.', 'Embedded Software Engineer', 'Detroit', 'MI'),
   ('2022-03-01', '2023-05-31', 'IBM', 'Implemented AI solutions for supply chain optimization.', 'Data Scientist', 'Armonk', 'NY'),
   ('2023-05-01', '2024-12-31', 'Cisco', 'Developed networking tools for enterprise solutions.', 'Network Engineer', 'San Jose', 'CA'),
   ('2020-09-01', '2021-11-30', 'Hewlett Packard', 'Optimized performance for enterprise printing solutions.', 'Software Engineer', 'Palo Alto', 'CA'),
   ('2021-06-01', '2022-07-31', 'Walmart', 'Built predictive analytics models for inventory management.', 'Data Analyst', 'Bentonville', 'AR'),
   ('2022-07-01', '2023-12-31', 'Spotify', 'Worked on cross-platform compatibility for music streaming.', 'Cross-Platform Engineer', 'New York', 'NY'),
   ('2023-02-01', '2024-12-31', 'Intel', 'Designed software for testing and validation of new hardware.', 'Software Engineer', 'Santa Clara', 'CA'),
   ('2020-01-01', '2021-03-31', 'SpaceX', 'Developed telemetry software for satellite communication.', 'Aerospace Software Engineer', 'Hawthorne', 'CA'),
   ('2021-10-01', '2022-12-31', 'Disney', 'Built mobile apps for Disney+ with advanced UI features.', 'Mobile App Developer', 'Burbank', 'CA'),
   ('2022-05-01', '2023-08-31', 'Ford', 'Developed navigation systems for autonomous vehicles.', 'Software Engineer', 'Dearborn', 'MI'),
   ('2023-06-01', '2024-12-31', 'Intel', 'Optimized embedded systems for IoT devices.', 'Embedded Software Engineer', 'Folsom', 'CA'),
   ('2020-07-01', '2021-09-30', 'eBay', 'Implemented search and filter tools for ecommerce products.', 'Backend Developer', 'San Jose', 'CA'),
   ('2021-09-01', '2023-09-30', 'Toyota', 'Developed systems for hybrid and electric vehicle software.', 'Software Engineer', 'Plano', 'TX'),
   ('2022-01-01', '2023-01-31', 'Pinterest', 'Worked on enhancing visual search tools for the platform.', 'Frontend Engineer', 'San Francisco', 'CA'),
   ('2023-08-01', '2024-12-31', 'Oracle', 'Developed high-availability database replication systems.', 'Database Administrator', 'Redwood City', 'CA'),
   ('2020-05-01', '2021-07-31', 'Sony', 'Created APIs for Playstation online services.', 'API Developer', 'San Mateo', 'CA'),
   ('2021-06-01', '2022-09-30', 'Samsung', 'Developed user interfaces for smart TV applications.', 'Frontend Developer', 'Plano', 'TX'),
   ('2022-09-01', '2023-12-31', 'Adobe', 'Built machine learning models for Photoshop enhancements.', 'Machine Learning Engineer', 'San Jose', 'CA'),
   ('2023-03-01', '2024-11-30', 'Netflix', 'Optimized video streaming algorithms for adaptive bitrate.', 'Streaming Engineer', 'Los Gatos', 'CA'),
   ('2020-10-01', '2021-12-31', 'Snapchat', 'Built augmented reality features for mobile apps.', 'AR Developer', 'Santa Monica', 'CA'),
   ('2021-08-01', '2023-01-31', 'PayPal', 'Designed payment processing solutions for mobile platforms.', 'Software Engineer', 'San Jose', 'CA'),
   ('2022-04-01', '2023-06-30', 'Target', 'Developed mobile apps for retail and customer rewards.', 'Mobile Developer', 'Minneapolis', 'MN'),
   ('2023-07-01', '2024-12-31', 'Starbucks', 'Built inventory management tools for store operations.', 'Software Engineer', 'Seattle', 'WA'),
   ('2020-11-01', '2021-12-31', 'Electronic Arts', 'Enhanced gameplay features for AAA video games.', 'Game Developer', 'Redwood City', 'CA'),
   ('2021-04-01', '2022-06-30', 'AT&T', 'Developed telecom solutions for 5G networks.', 'Software Engineer', 'Dallas', 'TX'),
   ('2022-02-01', '2023-03-31', 'Uber Eats', 'Enhanced real-time order tracking features for the app.', 'Full Stack Developer', 'San Francisco', 'CA'),
   ('2023-01-01', '2024-11-30', 'Robinhood', 'Built trading algorithms and portfolio tracking tools.', 'Software Engineer', 'Menlo Park', 'CA'),
   ('2020-06-01', '2021-07-31', 'Zoom', 'Designed breakout room features for large meetings.', 'Software Engineer', 'San Jose', 'CA'),
   ('2021-09-01', '2023-02-28', 'Intel', 'Developed FPGA tools for AI acceleration.', 'Hardware Software Engineer', 'Hillsboro', 'OR');


-- Insert Resume Experience
INSERT INTO ResumeExperience (ExperienceId, ResumeId)
VALUES
    # williamjackson
    (1, 1),
    (2, 1),
    (3, 1),

    # emilyking
    (4, 2),
    (5, 2),

    # benjaminlee
    (6, 3),
    (7, 3),
    (8, 3),

    # grace.mitchell
    (9, 4),

    (10, 5),
    (11, 5),
    (12, 6),
    (13, 7),
    (14, 7),
    (15, 8),
    (16, 9),
    (17, 9),
    (18, 10),
    (19, 11),
    (20, 11),
    (21, 12),
    (22, 13),
    (23, 13),
    (24, 14),
    (25, 14),
    (26, 15),
    (27, 16),
    (28, 16),
    (29, 17),
    (30, 18),
    (31, 19),
    (32, 19),
    (33, 20),
    (34, 21),
    (35, 21),
    (36, 22),
    (37, 23),
    (38, 23),
    (39, 24),
    (40, 25),
    (41, 26),
    (42, 26),
    (43, 27),
    (44, 28),
    (45, 29),
    (46, 30),
    (47, 31),
    (48, 32),
    (49, 33),
    (50, 34),
    (51, 35),
    (52, 36),
    (53, 37),
    (54, 37),
    (55, 38),
    (56, 39),
    (57, 40),
    (58, 40),
    (59, 40),
    (60, 40);


-- Insert Education
INSERT INTO Education (StartDate, EndDate, InstitutionName, Description, Degree)
VALUES
   ('2020-09-01', '2024-05-15', 'Harvard University', 'Studied Computer Science with a focus on software engineering and AI.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Stanford University', 'Studied Software Engineering with a focus on algorithms and machine learning.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'MIT', 'Studied Computer Science, specializing in artificial intelligence and data science.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of California, Berkeley', 'Studied Computer Science with a focus on cloud computing and cybersecurity.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Princeton University', 'Studied Electrical Engineering and Computer Science.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Yale University', 'Studied Computer Science with a focus on network systems and data structures.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Chicago', 'Studied Data Science and Machine Learning.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'Columbia University', 'Studied Software Engineering with a focus on AI and blockchain technology.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Southern California', 'Studied Computer Science with an emphasis on mobile app development.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Harvard University', 'Studied Data Science with an emphasis on statistical modeling and machine learning.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'Stanford University', 'Studied Computer Science with a focus on software systems and AI.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Northeastern University', 'Studied Computer Science with a focus on cybersecurity and machine learning.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'University of California, Los Angeles', 'Studied Data Science with a focus on data visualization and machine learning.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Michigan', 'Studied Computer Science with a focus on AI and software development.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Cornell University', 'Studied Cybersecurity and network security protocols.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'University of Texas at Austin', 'Studied Data Science with a focus on big data analytics.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Washington', 'Studied Computer Science with a focus on human-computer interaction and AI.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Georgia Tech', 'Studied Cybersecurity with a focus on digital forensics and network security.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'Duke University', 'Studied Data Science with an emphasis on machine learning and artificial intelligence.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Pennsylvania', 'Studied Computer Science with a focus on software engineering and databases.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Boston University', 'Studied Data Science with an emphasis on predictive modeling and analytics.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of North Carolina at Chapel Hill', 'Studied Computer Science with a focus on cloud computing and mobile development.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Illinois Urbana-Champaign', 'Studied Cybersecurity with a focus on cryptography and security protocols.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'Texas A&M University', 'Studied Data Science with a focus on statistical analysis and big data technologies.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Wisconsin-Madison', 'Studied Computer Science with a focus on machine learning and artificial intelligence.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Purdue University', 'Studied Computer Science with a focus on software engineering and cloud platforms.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Florida', 'Studied Data Science with an emphasis on data mining and visualization.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Maryland, College Park', 'Studied Cybersecurity with a focus on ethical hacking and network security.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'Ohio State University', 'Studied Computer Science with a focus on software engineering and systems programming.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Arizona', 'Studied Data Science with an emphasis on statistical analysis and machine learning.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Miami', 'Studied Computer Science with a focus on AI and software engineering.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Minnesota', 'Studied Cybersecurity with a focus on digital security and privacy laws.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'Indiana University Bloomington', 'Studied Data Science with an emphasis on algorithms and big data technologies.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Colorado Boulder', 'Studied Computer Science with a focus on AI and robotics.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'University of Connecticut', 'Studied Cybersecurity with a focus on network defense and risk management.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'University of Pittsburgh', 'Studied Data Science with an emphasis on machine learning and data analytics.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'Florida State University', 'Studied Computer Science with a focus on software engineering and data analytics.', 'B.S. Computer Science'),
   ('2020-09-01', '2024-05-15', 'Clemson University', 'Studied Data Science with an emphasis on artificial intelligence and machine learning.', 'B.S. Data Science'),
   ('2020-09-01', '2024-05-15', 'University of Georgia', 'Studied Cybersecurity with a focus on network security and cloud solutions.', 'B.S. Cybersecurity'),
   ('2020-09-01', '2024-05-15', 'University of Oklahoma', 'Studied Computer Science with a focus on software engineering and mobile app development.', 'B.S. Computer Science');


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
   (11, 11),
   (12, 12),
   (13, 13),
   (14, 14),
   (15, 15),
   (16, 16),
   (17, 17),
   (18, 18),
   (19, 19),
   (20, 20),
   (21, 21),
   (22, 22),
   (23, 23),
   (24, 24),
   (25, 25),
   (26, 26),
   (27, 27),
   (28, 28),
   (29, 29),
   (30, 30),
   (31, 31),
   (32, 32),
   (33, 33),
   (34, 34),
   (35, 35),
   (36, 36),
   (37, 37),
   (38, 38),
   (39, 39),
   (40, 40);


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
   ((SELECT Id FROM Company WHERE Name = 'Shopify'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-10-15'),

   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-01-20'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-01-25'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-02-10'),
   ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-02-15'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-03-05'),
   ((SELECT Id FROM Company WHERE Name = 'Atlassian'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-03-10'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'ethanunderwood@example.com'), '2024-04-01'),

   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-01-15'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-01-18'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-02-07'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-02-12'),
   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-03-07'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com'), '2024-04-01'),

   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), '2024-02-01'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), '2024-02-05'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), '2024-02-15'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), '2024-03-05'),
   ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT UUID FROM User WHERE Email = 'kylemitchell@example.com'), '2024-03-10'),

   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'albertackley@example.com'), '2024-02-25'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'albertackley@example.com'), '2024-03-01'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'brianbeck@example.com'), '2024-02-08'),
   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'brianbeck@example.com'), '2024-02-12'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'brianbeck@example.com'), '2024-03-02'),

   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'charlieclouds@example.com'), '2024-01-28'),
   ((SELECT Id FROM Company WHERE Name = 'Tesla'), (SELECT UUID FROM User WHERE Email = 'charlieclouds@example.com'), '2024-02-02'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'danieldownes@example.com'), '2024-02-18'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'danieldownes@example.com'), '2024-02-22'),
   ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT UUID FROM User WHERE Email = 'danieldownes@example.com'), '2024-03-12'),

   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), '2024-01-11'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), '2024-01-20'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), '2024-02-01'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), '2024-02-10'),
   ((SELECT Id FROM Company WHERE Name = 'Salesforce'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com'), '2024-02-18'),

   ((SELECT Id FROM Company WHERE Name = 'Nike'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), '2024-03-01'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), '2024-03-07'),
   ((SELECT Id FROM Company WHERE Name = 'Tesla'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), '2024-03-15'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), '2024-03-20'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com'), '2024-04-01'),

   ((SELECT Id FROM Company WHERE Name = 'Microsoft'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), '2024-01-30'),
   ((SELECT Id FROM Company WHERE Name = 'Spotify'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), '2024-02-15'),
   ((SELECT Id FROM Company WHERE Name = 'Google'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), '2024-02-20'),
   ((SELECT Id FROM Company WHERE Name = 'Amazon'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), '2024-03-10'),
   ((SELECT Id FROM Company WHERE Name = 'IBM'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com'), '2024-03-18');


-- Insert ResumeCompany
INSERT INTO ResumeCompany (CompanyId, ResumeId)
SELECT
    c.Id,
    re.ResumeId
FROM ResumeExperience re
JOIN Experience e ON re.ExperienceId = e.Id
JOIN Company c ON e.CompanyName = c.Name;


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
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Aria Vargas'), (SELECT UUID FROM User WHERE Email = 'ariavargas@example.com')),

    ((SELECT ResumeId FROM Resumes WHERE Name = 'Albert Ackley'), (SELECT UUID FROM User WHERE Email = 'albertackley@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Brian Beck'), (SELECT UUID FROM User WHERE Email = 'brianbeck@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Charlie Clouds'), (SELECT UUID FROM User WHERE Email = 'charlieclouds@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Daniel Downes'), (SELECT UUID FROM User WHERE Email = 'danieldownes@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Emilio Earhart'), (SELECT UUID FROM User WHERE Email = 'emilioearhart@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Frances Fisher'), (SELECT UUID FROM User WHERE Email = 'francesfisher@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Gregory Gill'), (SELECT UUID FROM User WHERE Email = 'gregorygill@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Harriett Hughes'), (SELECT UUID FROM User WHERE Email = 'harrietthughes@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Indiana Iglesias'), (SELECT UUID FROM User WHERE Email = 'indianaiglesias@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Jeremy Jones'), (SELECT UUID FROM User WHERE Email = 'jeremyjones@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Kevin King'), (SELECT UUID FROM User WHERE Email = 'kevinking@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Liam Lansing'), (SELECT UUID FROM User WHERE Email = 'liamlansing@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Monty Mills'), (SELECT UUID FROM User WHERE Email = 'montymills@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Nora Nathan'), (SELECT UUID FROM User WHERE Email = 'noranathan@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Oscar Ophelia'), (SELECT UUID FROM User WHERE Email = 'oscarophelia@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Pedro Pascal'), (SELECT UUID FROM User WHERE Email = 'pedropascal@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Quinn Quixote'), (SELECT UUID FROM User WHERE Email = 'quinnquixote@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Ryan Richards'), (SELECT UUID FROM User WHERE Email = 'ryanrichards@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Steven Seagull'), (SELECT UUID FROM User WHERE Email = 'stevenseagull@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Theodore Till'), (SELECT UUID FROM User WHERE Email = 'theodoretill@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Ulysses Unicorn'), (SELECT UUID FROM User WHERE Email = 'ulyssesunicorn@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Victor Vera'), (SELECT UUID FROM User WHERE Email = 'victorvera@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Wyatt Wings'), (SELECT UUID FROM User WHERE Email = 'wyattwings@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Xavier Xim'), (SELECT UUID FROM User WHERE Email = 'xavierxim@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Yennifer Young'), (SELECT UUID FROM User WHERE Email = 'yenniferyoung@example.com')),
    ((SELECT ResumeId FROM Resumes WHERE Name = 'Zonda Zachary'), (SELECT UUID FROM User WHERE Email = 'zondazachary@example.com'));
