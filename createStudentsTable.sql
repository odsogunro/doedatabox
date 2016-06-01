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


/*
 * ===============================
 * CREATE TABLES
 */
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
 * =============================== 
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

UPDATE scores SET subject = 'ELA' WHERE subject == 'ela';

DELETE FROM demographics
WHERE studentID == 'StudentID';

DELETE FROM schools
WHERE studentID == 'StudentID';

/*
SELECT * FROM scores;

SELECT * FROM demographics;

SELECT * FROM schools;
*/

/* 
 * ===============================
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
 
-- temp students
--CREATE TEMP TABLE IF NOT EXISTS students (
CREATE TEMP TABLE temp_students (
	studentID TEXT, 
	subject TEXT, 
	school TEXT, 
	specialEd TEXT, 
	ell TEXT,
	score REAL);

/*
 * 
 */

/*
SELECT COUNT(studentID)
	FROM students;

SELECT * 
	FROM students;

SELECT COUNT(studentID) 
	FROM students
	WHERE subject IN ('ELA', 'Math')
		AND score IS NOT NULL;

SELECT *
	FROM students
	WHERE subject IN ('ELA', 'Math')
		AND score IS NOT NULL;
*/

SELECT COUNT(studentID)
	FROM (SELECT studentID, subject, school, specialEd, ell, AVG(score) 
			FROM students
			WHERE subject IN ('ELA', 'Math')
				AND score IS NOT NULL
			GROUP BY subject, studentID
		 );

SELECT studentID, subject, school, specialEd, ell, AVG(score)
	FROM students
	WHERE subject IN ('ELA', 'Math')
		AND score IS NOT NULL
	GROUP BY subject, studentID;

INSERT INTO temp_students
	SELECT studentID, subject, school, specialEd, ell, AVG(score)
		FROM students
		WHERE subject IN ('ELA', 'Math')
			AND score IS NOT NULL
		GROUP BY subject, studentID;

/*
 * ===============================
 * PASS RATE QUERIES on TEMP TABLE temp_students
 */

-- A1) pass rate by school
SELECT s1.school, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateBySchool
	FROM (SELECT school, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
			GROUP BY school) s1
	CROSS JOIN (SELECT school, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY school) s2
	ON s1.school == s2.school
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateBySchool
	FROM (SELECT school, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
			GROUP BY school) s1
	CROSS JOIN (SELECT school, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY school) s2
	ON s1.school == s2.school;

-- A2) pass rate by subject
SELECT s1.subject, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateBySubject
	FROM (SELECT subject, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND subject != 'SOC'
			GROUP BY subject) s1
	CROSS JOIN (SELECT subject, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY subject) s2
	ON s1.subject == s2.subject
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateBySubject
	FROM (SELECT subject, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND subject != 'SOC'
			GROUP BY subject) s1
	CROSS JOIN (SELECT subject, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY subject) s2
	ON s1.subject == s2.subject;

-- A3i) pass rate by all students
SELECT s1.studentID, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateByAllStudents
	FROM (SELECT studentID, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND subject != 'SOC'
			GROUP BY studentID) s1
	CROSS JOIN (SELECT studentID, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY studentID) s2
	ON s1.studentID == s2.studentID
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateByAllStudents
	FROM (SELECT studentID, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND subject != 'SOC'
			GROUP BY studentID) s1
	CROSS JOIN (SELECT studentID, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY studentID) s2
	ON s1.studentID == s2.studentID;

-- A3ii) pass rate by ell students
---- TODO: Sum all!!!! Use "UNION ALL"
SELECT s1.ell, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateByEllStudents
	FROM (SELECT ell, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND ell IN ('A', 'E', 'I', 'O', 'U')
--			) s1
			GROUP BY ell) s1
	CROSS JOIN (SELECT ell, COUNT(studentID) cnt
					FROM temp_students
--					) s2
					GROUP BY ell) s2
	ON s1.ell == s2.ell
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateByEllStudents
	FROM (SELECT ell, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND ell IN ('A', 'E', 'I', 'O', 'U')
--			) s1
			GROUP BY ell) s1
	CROSS JOIN (SELECT ell, COUNT(studentID) cnt
					FROM temp_students
--					) s2
					GROUP BY ell) s2
	ON s1.ell == s2.ell;

-- A3iii) pass rate by special ed students
SELECT s1.specialEd, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateBySpecialEdStudents
	FROM (SELECT specialEd, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND specialEd == 'Y'
--			) s1
			GROUP BY specialEd) s1
	CROSS JOIN (SELECT specialEd, COUNT(studentID) cnt
					FROM temp_students
--					) s2
					GROUP BY specialEd) s2
	ON s1.specialEd == s2.specialEd
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateBySpecialEdStudents
	FROM (SELECT specialEd, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND specialEd == 'Y'
--			) s1
			GROUP BY specialEd) s1
	CROSS JOIN (SELECT specialEd, COUNT(studentID) cnt
					FROM temp_students
--					) s2
					GROUP BY specialEd) s2
	ON s1.specialEd == s2.specialEd;

-- A3iv) pass rate by both ell and special ed students
SELECT s1.specialEd, s1.cnt, s2.cnt, CAST(s1.cnt AS REAL) / CAST(s2.cnt AS REAL) AS passRateByEllAndSpecialEdStudents
	FROM (SELECT specialEd, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND ell IN ('A', 'E', 'I', 'O', 'U')
				AND specialEd == 'Y'
			GROUP BY specialEd) s1
	CROSS JOIN (SELECT specialEd, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY specialEd) s2
	ON s1.specialEd == s2.specialEd
UNION ALL
SELECT 'TOTAL', SUM(s1.cnt), SUM(s2.cnt), CAST(SUM(s1.cnt) AS REAL) / CAST(SUM(s2.cnt) AS REAL) AS passRateByEllAndSpecialEdStudents
	FROM (SELECT specialEd, COUNT(studentID) cnt
			FROM temp_students
			WHERE score >= 65.0
				AND ell IN ('A', 'E', 'I', 'O', 'U')
				AND specialEd == 'Y'
			GROUP BY specialEd) s1
	CROSS JOIN (SELECT specialEd, COUNT(studentID) cnt
					FROM temp_students
					GROUP BY specialEd) s2
	ON s1.specialEd == s2.specialEd;


/*
 * B)student level dataset -> studentLevel.txt
 * 		B1) ell = 1, otherwise ell = 0
 * 		B2) speacialEd = 1, otherwise = specialEd = 0
 * 		B3) leave value empty for not taking an exam i.e. NULL 
 */
CREATE TEMP TABLE temp_studentsLevel (
	studentID TEXT,  
	school TEXT, 
	scoreMath REAL,
	scoreELA REAL,
	passMath INTEGER,
	passELA INTEGER, 
	inEll INTEGER,
	inSpecialEd INTEGER);

INSERT INTO temp_studentsLevel 
	SELECT studentID, 
		   school, 
		   CASE WHEN subject = 'Math' AND score >= 65.0 THEN score ELSE 0.0 END scoreMath,
		   CASE WHEN subject = 'ELA' AND score >= 65.0 THEN score ELSE 0.0 END scoreELA,
		   CASE WHEN subject = 'Math' AND score >= 65.0 THEN 1 ELSE 0 END passedMath,
		   CASE WHEN subject = 'ELA' AND score >= 65.0 THEN 1 ELSE 0 END passedELA,
		   CASE WHEN ell IN ('A', 'E', 'I', 'O', 'U') THEN 1 ELSE 0 END inEll,
		   CASE WHEN specialEd = 'Y' THEN 1 ELSE 0 END inSpecialEd   
		FROM temp_students;

-- db settings
.mode tabs
.separator "\t"

.output "data/studentsLevel.txt"

SELECT * 
	FROM temp_studentsLevel;

.mode column
.separator "\t"
.output stdout

SELECT * 
	FROM temp_studentsLevel;
/*
 * DROP TABLES: system cleanup
 * 
 */
DROP TABLE scores;
DROP TABLE demographics;
DROP TABLE schools;
DROP TABLE students;
DROP TABLE temp.temp_students;
DROP TABLE temp.temp_scores_schools;
DROP TABLE temp.temp_studentsLevel;

--.exit