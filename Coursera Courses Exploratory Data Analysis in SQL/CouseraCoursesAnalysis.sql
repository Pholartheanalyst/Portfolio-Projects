
/*COURSERA COURSES EXPLORATORY DATA ANALYSIS (BASIC SQL) */
/*FOLASHADE OLAITAN*/


---View the dataset
SELECT * 
FROM SQLProjects.dbo.coursera_data$

---Capitalize the certificate types
--UPDATE SQLProjects..coursera_data$
--SET Course_Certificate_type = INITCAP(Course_Certificate_type)

--Changing the data type for Course_ID from float to character as I do not want to make calculations on it.
UPDATE SQLProjects..coursera_data$
SET Course_ID = CAST(Course_ID as Nvarchar(255))


----How many total courses are being offered? Counting by Course_ID.
SELECT CAST(COUNT(Course_ID) as Nvarchar) as Total_CourseIDs
		,COUNT(DISTINCT Course_Title) as Unique_Courses
		,COUNT(Course_Title) as Total_Courses
FROM SQLProjects.dbo.coursera_data$


----10 Most Popular Courses Based on Number of Enrolled Students
----This SQL version does not support the LIMIT clause, so i have used TOP 10 instead
SELECT TOP 10 Course_title, SUM(Number_of_Enrolled_Students) as Total_Enrollments
FROM SQLProjects.dbo.coursera_data$
GROUP BY Course_title
ORDER BY SUM(Number_of_Enrolled_Students) DESC


----Courses with average ratings greater than 4.8
SELECT Course_title as Course, AVG(Course_rating) as Total_Ratings
FROM SQLProjects.dbo.coursera_data$
GROUP BY Course_title
HAVING AVG(Course_rating) > 4.8
ORDER BY AVG(Course_rating) DESC



----Top 15 Awarding Body with the highest number of courses and number of enrolled students
SELECT TOP 15 Course_organization as Awarding_Body,
       COUNT(Course_title) as Total_Courses_Offered, 
	   SUM(Number_of_Enrolled_Students) as Total_Enrollments
FROM SQLProjects.dbo.coursera_data$
GROUP BY Course_organization
ORDER BY COUNT(Course_title) DESC, SUM(Number_of_Enrolled_Students) DESC



--Which Awarding Bodies offer the AI, ML and Data Science Courses? Interestingly, these are the top courses offered
--THESE ARE THE BODIES I WANT TO PARTNER WITH

SELECT Course_organization as Awarding_Body,
		Course_title,
		SUM(Number_of_Enrolled_Students) as Total_Enrollments
FROM SQLProjects.dbo.coursera_data$
WHERE Course_title IN ('Machine Learning', 'The Science of Well-Being', 'Python for Everybody',
						'Programming for Everybody (Getting Started with Python', 'Data Science',
						'Career Success', 'Data Science: Foundations Using R', 'Deep Learning', 
						'Neural Networks and Deep Learning')
GROUP BY Course_organization, Course_title
ORDER BY SUM(Number_of_Enrolled_Students) DESC

--NOTE: The above can also be written by using SubQueries (see next query)
--which saves the energy of having to type out the IN clause manually

--Which Awarding Bodies offer the Top 10 enrolled courses?--THESE ARE THE BODIES I WANT TO PARTNER WITH
SELECT Course_organization as Awarding_Body,
		Course_title,
		SUM(Number_of_Enrolled_Students) as Total_Enrollments
FROM SQLProjects.dbo.coursera_data$
WHERE Course_title IN (
					SELECT TOP 10 Course_title
					FROM SQLProjects.dbo.coursera_data$
					GROUP BY Course_title
					ORDER BY SUM(Number_of_Enrolled_Students) DESC
						)
GROUP BY Course_organization, Course_title
ORDER BY SUM(Number_of_Enrolled_Students) DESC



----What is the total number of courses per level,number of enrolled students, and % of the total enrolled students
WITH AllStudents (Total_Enrolments_All_Levels) as (
SELECT SUM(Number_of_Enrolled_Students)
FROM SQLProjects.dbo.coursera_data$
)
SELECT Cou.Course_difficulty as Course_Level,
		COUNT(Cou.Course_title) as Total_Courses_Per_Level, 
		SUM(Cou.Number_of_Enrolled_Students) as Enrolled_Students_Per_Level,
		Total_Enrolments_All_Levels,
		ROUND((SUM(Cou.Number_of_Enrolled_Students)/Total_Enrolments_All_Levels)*100, 2) as Perc_Enrolment,
		ROUND(AVG(Course_rating),2) as Average_Rating
FROM SQLProjects.dbo.coursera_data$ Cou, AllStudents
GROUP BY Cou.Course_difficulty,Total_Enrolments_All_Levels
ORDER BY (SUM(Cou.Number_of_Enrolled_Students)/Total_Enrolments_All_Levels)*100 DESC



-----What is the average enrolment and average rating per certification type?
SELECT Course_Certificate_type as Certification_Type,
		CAST(SUM(Number_of_Enrolled_Students)as int) as Total_Enrollments,
		CAST(AVG(Number_of_Enrolled_Students)as int) as Average_Enrollments,
		COUNT(Course_ID) as Number_of_Courses,
		ROUND(AVG(Course_rating),2) as Average_Rating
FROM SQLProjects.dbo.coursera_data$
GROUP BY Course_Certificate_type
ORDER BY CAST(SUM(Number_of_Enrolled_Students)as int) DESC, CAST(AVG(Number_of_Enrolled_Students)as int) DESC


----COURSE Certificate type has the HIGHEST TOTAL enrolments 
----While the PROFESSIONAL Certificate has the HIGHEST AVERAGE enrolments
----What courses are COMMON to BOTH certificate types?
WITH Courses as (
SELECT Course_ID, Course_title
FROM SQLProjects.dbo.coursera_data$
WHERE Course_Certificate_type = 'course'
)
Professional as (
SELECT Course_ID, Course_title
FROM SQLProjects.dbo.coursera_data$
WHERE Course_Certificate_type = 'professional certificate'
)
SELECT *
FROM Courses C, Professional P
WHERE C.Course_ID = P.Course_ID