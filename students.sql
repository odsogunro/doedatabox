/* 
 * SQLite3 
 */

-- scores
CREATE TABLE IF NOT EXISTS scores (
	studentID TEXT, 
	subject TEXT, 
	score TEXT);


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
	score TEXT, 
	school TEXT, 
	specialEd TEXT, 
	ell TEXT);
