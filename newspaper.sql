/* Troy Curtsinger, Nathan Williams,
		Ryan Dimaran, Reevan M.
    
    A database which represents a school newspaper
    for the UTD ECS school
    (more or less)
    */

/*	create a new version of the newspaper Database
	and remove any previous versions	*/
DROP DATABASE IF EXISTS johnnsonNewsPaper;
CREATE DATABASE johnnsonNewsPaper;
USE johnnsonNewsPaper;

/*	the actual tables of the database */

CREATE TABLE Newspaper (
	issueID 			INT				NOT NULL		PRIMARY KEY		AUTO_INCREMENT,
	title 				VARCHAR(100)	NOT NULL,
	webAddress 			VARCHAR(500)	NOT NULL,
	releaseDate 		DATE			NOT NULL
);

CREATE TABLE Users (
	userID  			INT 			NOT NULL		PRIMARY KEY  	AUTO_INCREMENT,
	firstName    		VARCHAR(100)	NOT NULL,
	lastName 			VARCHAR(100)	NOT NULL,
	DOB 				DATE,
	email 				VARCHAR(100),
	firstIssueID 		INT				NOT NULL,
    subscribedDate		DATE			NOT NULL,
	userType 			VARCHAR(50)		NOT NULL,
	
    FOREIGN KEY (firstIssueID)
		REFERENCES Newspaper(issueID)
);

CREATE TABLE Student (
	userID 				INT 			NOT NULL		PRIMARY KEY,
	year 				VARCHAR(12),
	major 				VARCHAR(100),
    studentType			VARCHAR(15),
  
  FOREIGN KEY (userID)
	REFERENCES Users(userID)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE FacultySponsor (
	userID 				INT				NOT NULL		PRIMARY KEY,
	department 			VARCHAR(100),
  
  FOREIGN KEY (userID)
	REFERENCES Users(userID)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE Author (
	userID 				INT				NOT NULL		PRIMARY KEY,
	penName 			VARCHAR(100),
	numSemesters 		INT,		
	specialty 			VARCHAR(50),
	sponsorID 			INT,

	FOREIGN KEY (userID)
	REFERENCES Users(userID)
		ON DELETE CASCADE,
  
  FOREIGN KEY (SponsorID)
	REFERENCES Users(userID)
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Editor (
	userID 				INT 			NOT NULL		PRIMARY KEY,
	type 				VARCHAR(15),
	numSemesters 		INT,
	SponsorID 			INT,

	FOREIGN KEY (userID)
	REFERENCES Users(userID)
		ON DELETE CASCADE,
  
  FOREIGN KEY (SponsorID)
	REFERENCES Users(userID)
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Article (
	articleID 			INT 			NOT NULL		PRIMARY KEY,
	issueID 			INT				NOT NULL,
	title 				VARCHAR(100)	NOT NULL,
	type 				VARCHAR(12)		NOT NULL,
	editorID 			INT,
	authorID 			INT,
  
  FOREIGN KEY (issueID)
	REFERENCES Newspaper(issueID)
		ON DELETE CASCADE ON UPDATE CASCADE,
  
  FOREIGN KEY (editorID)
	REFERENCES Editor(userID)
		ON DELETE SET NULL ON UPDATE CASCADE,
  
  FOREIGN KEY (authorID)
	REFERENCES Author(userID)
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Image (
	title 				VARCHAR(100)	NOT NULL,
	articleID 			INT				NOT NULL,
	webAddress 			VARCHAR(500)	NOT NULL,
	imageDate 			DATE,
  
  UNIQUE KEY(title, articleID),
  
  FOREIGN KEY (articleID)
	REFERENCES Article(articleID)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Event (
	articleID 			INT				NOT NULL		PRIMARY KEY,
	eventName 			VARCHAR(100),
	eventDate 			DATE,
	eventContent 		LONGTEXT,
  
  FOREIGN KEY (articleID)
	REFERENCES Article(articleID)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Research (
	articleID 			INT 			NOT NULL		PRIMARY KEY,
	labName 			VARCHAR(100),
	researchContent		LONGTEXT,
  
  FOREIGN KEY (articleID)
	REFERENCES Article(articleID)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Project (
	articleID 			INT				NOT NULL		PRIMARY KEY,
	projectDescription 	VARCHAR(500),
	projectContent 		LONGTEXT,
  
  FOREIGN KEY (articleID)
	REFERENCES Article(articleID)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Organization (
	articleID 			INT				NOT NULL		PRIMARY KEY,
	orgName 			VARCHAR(500),
	orgContent 			LONGTEXT,
  
  FOREIGN KEY (articleID)
	REFERENCES Article(articleID)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/*
-- TRIGGERs
*/
-- User Table
DELIMITER #
CREATE TRIGGER UserAfterInsertChildTables AFTER INSERT ON Users
FOR EACH ROW
BEGIN
	IF NEW.userType = 'Student' THEN
        INSERT INTO Student (UserID) VALUES (NEW.UserID);
	ELSEIF NEW.userType = 'FacultySponsor' THEN
		INSERT INTO FacultySponsor (UserID) VALUES (NEW.UserID);
	END IF;
END #

-- Student Table
CREATE TRIGGER StudentAfterUpdateChildTables AFTER UPDATE ON Student
FOR EACH ROW
BEGIN
	IF NEW.studentType = 'Author' THEN
        INSERT INTO Author (UserID) VALUES (NEW.UserID);
	ELSEIF NEW.studentType = 'Editor' THEN
		INSERT INTO Editor (UserID) VALUES (NEW.UserID);
	END IF;
END #

-- Event Table
CREATE TRIGGER ArticleInsertUpdateChildTables AFTER INSERT ON Article
FOR EACH ROW
BEGIN
	IF NEW.type = 'Event' THEN
        INSERT INTO Event (articleID) VALUES (NEW.articleID);
	ELSEIF NEW.type = 'Research' THEN
		INSERT INTO Research (articleID) VALUES (NEW.articleID);
	ELSEIF NEW.type = 'Project' THEN
		INSERT INTO Project (articleID) VALUES (NEW.articleID);
	ELSE
		INSERT INTO Organization (articleID) VALUES (NEW.articleID);
	END IF;
END #



-- Stored Procedures
DELIMITER //
CREATE PROCEDURE aboutStudent(
IN first VARCHAR(100),
IN last VARCHAR(100)
)
BEGIN 
SELECT *
FROM studentInfo
WHERE firstName = first and lastName = last;
END//


DELIMITER //
CREATE PROCEDURE aboutTheAuthor(
IN first VARCHAR(100),
IN last VARCHAR(100)
)
BEGIN 
SELECT  *
FROM authorInfo
WHERE firstName = first and lastName = last;
END//

DELIMITER ;



-- Views

DROP VIEW IF EXISTS studentInfo;
CREATE VIEW studentInfo AS
SELECT u.firstName, u.lastName, u.subscribedDate, s.year, s.major 
FROM Users AS u
INNER JOIN Student AS s ON u.userID = s.userID;  

DROP VIEW IF EXISTS authorInfo;
CREATE VIEW authorInfo AS
SELECT a.penName, u.firstName, u.lastName, s.year, s.major, a.numSemesters, a.specialty
FROM Users AS u
INNER JOIN Student AS s ON u.userID = s.userID
INNER JOIN Author AS a ON u.userID = a.userID;

DROP VIEW IF EXISTS editorinfo;
CREATE VIEW editorinfo AS
SELECT u.firstName, u.lastName, s.year, s.major, e.type, e.numSemesters
FROM Users AS u
INNER JOIN Student AS s ON u.userID = s.userID
INNER JOIN Editor AS e ON u.userID = e.userID

-- Example Queries
3.

DROP VIEW IF EXISTS authorInfo;
CREATE VIEW authorInfo AS
SELECT a.penName, u.firstName, u.lastName, s.year, s.major, a.numSemesters, a.specialty, f.department
FROM Users AS u
INNER JOIN Student AS s ON u.userID = s.userID
INNER JOIN Author AS a ON u.userID = a.userID
INNER JOIN FacultySponsor AS f ON a.sponsorID = f.userID;

4. Num of new users per issue

SELECT 
    COUNT(userID) AS numNewUsers,
    title,
    (SELECT COUNT(userID) FROM newspaper n2 JOIN users ON users.firstIssueID = n2.issueID WHERE n2.issueID <= n1.issueID) as totalUsers
FROM
    newspaper n1
        JOIN
    users ON firstIssueID = issueID
GROUP BY issueID;

5. Sorted by date and time

SELECT a.title, a.type, n.releaseDate
FROM Article as a
INNER JOIN Newspaper as n ON a.issueID = n.issueID
ORDER BY releaseDate asc;
