/* 
 * Author: Dami Kazeem
 * Date: 20150528
 * SQLite3 CREATE TABLES
 * 
 */

-- db settings
.headers ON 
.mode list 
.separator "\t"

-- scores
CREATE TABLE IF NOT EXISTS scores (
	studentID TEXT, 
	subject TEXT, 
	score REAL);

-- demogrphics
CREATE TABLE IF NOT EXISTS demographics (
	studentID TEXT, 
	specialEd TEXT, 
	ell TEXT);

-- schools
CREATE TABLE IF NOT EXISTS schools (
	studentID TEXT, 
	school TEXT);

-- students
CREATE TABLE IF NOT EXISTS students (
	studentID TEXT, 
	subject TEXT, 
	score REAL, 
	school TEXT, 
	specialEd TEXT, 
	ell TEXT);

/* 
 * BULK INSERT DATA
 */

.import "data/scores.txt" scores
.import "data/Demographics.txt" demographics
.import "data/schools.txt" schools

/*.import "data/scores.csv" scores
.import "data/demographics.csv" demographics
.import "data/schools.csv" schools*/

/* SELECT * FROM scores; */
/* SELECT * FROM schools; */
/* SELECT * FROM demographics; */
/*.import "data/demoTestFix1.txt" demographics*/

/*
int sqlite3_exec(sqlite3* student.db, "INSERT INTO scores VALUES ('%s', '%s','%s')",
                 getID.c_str(), getID.c_str(), getID.c_str()) 
                );
*/