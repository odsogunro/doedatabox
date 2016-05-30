/* 
 * Author: Dami Kazeem
 * Date: 20150528
 * SQLite3 CREATE TABLES
 * 
 */

-- db settings
.headers ON 
.mode column 
.separator "\t"

-- scores
--CREATE TABLE IF NOT EXISTS scores (
CREATE TABLE scores (
	studentID TEXT, 
	subject TEXT, 
	score REAL);

-- demogrphics
--CREATE TABLE IF NOT EXISTS demographics (
CREATE TABLE demographics (
	studentID TEXT, 
	specialEd TEXT, 
	ell TEXT);

-- schools
--CREATE TABLE IF NOT EXISTS schools (
CREATE TABLE schools (
	studentID TEXT, 
	school TEXT);

-- students
--CREATE TABLE IF NOT EXISTS students (
CREATE TABLE students (
	studentID TEXT, 
	subject TEXT, 
	school TEXT, 
	specialEd TEXT, 
	ell TEXT,
	score REAL);

/* 
 * BULK INSERT DATA
 */

.import "data/scoresClean.txt" scores
.import "data/demographicsClean.txt" demographics
.import "data/schoolsClean.txt" schools
/*
 * CLEANUP TABLES
 */
DELETE FROM scores 
WHERE studentID == 'StudentID';

DELETE FROM demographics
WHERE studentID == 'StudentID';

DELETE FROM schools
WHERE studentID == 'StudentID';

/*SELECT * FROM scores;

SELECT * FROM demographics;

SELECT * FROM schools;*/

/*
 * CREATE QUERY FOR LOADING DATA 
 * TO students TABLE
 *
 * csvjoin -t --outer -c StudentID data/scores.txt data/schools.txt data/Demographics.txt | csvlook
 */

CREATE TEMP TABLE temp_scores_schools (
	studentID TEXT, 
	subject TEXT,
	school TEXT, 
	score REAL);


INSERT INTO temp_scores_schools
	SELECT sco.studentID, sco.subject, sch.school, sco.score 
		FROM scores AS sco 
		LEFT OUTER JOIN schools AS sch 
		ON sco.studentID = sch.studentID
	UNION ALL
	SELECT sch.studentID, sco.subject, sch.school, sco.score 
		FROM schools AS sch 
		LEFT OUTER JOIN scores AS sco 
		ON sch.studentID = sco.studentID 
		WHERE sco.studentID IS NULL; 


INSERT INTO students
	SELECT t.studentID, t.subject, t.school, dem.specialEd, dem.ell, t.score
		FROM temp_scores_schools AS t
		LEFT OUTER JOIN demographics AS dem
		ON t.studentID = dem.studentID
	UNION ALL
	SELECT dem.studentID, t.subject, t.school, dem.specialEd, dem.ell, t.score
		FROM demographics AS dem
		LEFT OUTER JOIN temp_scores_schools AS t
		ON dem.studentID = t.studentID
		WHERE t.studentID IS NULL;

SELECT * 
	FROM students;


SELECT * 
	FROM students
	ORDER BY studentID ASC;

SELECT school, COUNT(studentID) 
	FROM students
	WHERE score < 65.0
	GROUP BY school;

SELECT school, COUNT(studentID) 
	FROM students
	WHERE score >= 65.0
	GROUP BY school;

SELECT school, COUNT(studentID) 
	FROM students
	GROUP BY school;

/*
SELECT s1.school, COUNT(s1.studentID), COUNT(s1.studentID) / s2.totalCnt AS passRate 
	FROM students AS s1
	LEFT OUTER JOIN (SELECT school, COUNT(studentID) AS totalCnt FROM students GROUP BY school) s2 ON s1.school = s2.school 
	WHERE s1.score >= 65.0
	GROUP BY s1.school;
*/
.quit
.exit