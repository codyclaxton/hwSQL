--Cody Claxton
--Yoga instructors project
SET SERVEROUTPUT on;
SET LINESIZE 140;

DROP TRIGGER log_Yoga_Refund_Trigger;
DROP TRIGGER highAttend_Trigger;
DROP TRIGGER expLevel_Trigger;
DROP TABLE Log_Refund_Yoga;
DROP TABLE Enroll;
DROP TABLE highAttend;
DROP TABLE Class;
DROP TABLE Student;
DROP TABLE Instructor;
DROP SEQUENCE Log_seq;
DROP SEQUENCE Log_Refund_seq;


CREATE TABLE Instructor (
TID INT
,Fname VARCHAR2(15) NOT NULL
,Lname VARCHAR2(15) NOT NULL
,City VARCHAR2(15)
,State char(2)
,Rate_hour number(6,2) NOT NULL
,Constraint TID_PK Primary Key (TID)
);

CREATE TABLE Student(
SID INT
,First VARCHAR2(15) NOT NULL
,Last VARCHAR2(15) NOT NULL
,Exp_Level char(1) NOT NULL
,city VARCHAR2(15)
,State char(2)
,Constraint SID_PK Primary Key (SID)
,Constraint CHK_EXP CHECK (Exp_Level in ('B','I','E'))
);

Create Table Class
(
        Name varchar2(15) NOT NULL
        ,Duration int
        ,Class_Level char
        ,TID int
        ,Day varchar2(10) NOT NULL
        ,Time varchar2(10) NOT NULL
        ,Cost number(6,2)
        ,classCount int
        ,Constraint N_PK Primary Key (Name)
        ,Constraint TID_FK Foreign Key (TID) References Instructor(TID)
        ,Constraint CHK_DAY CHECK (Day in ('Mon','Tues','Wed','Thurs','Sat'))
        ,Constraint CHK_CLVL CHECK (Class_Level in ('B','I','E','A'))
);

CREATE TABLE highAttend
(
LogID INT
,Name VARCHAR2(15)
,log_Date date
,Constraint LID_PK Primary Key (LogID)
,Constraint higAtt_FK Foreign Key (Name) References Class(Name)
);


Create Table Enroll
(
        Class_Name varchar2(15)
        ,TID int
        ,SID int
        ,Payment int
        ,Constraint Class_PK Primary Key (Class_Name, TID, SID)
  ,Constraint Enroll_TID_FK Foreign Key(TID) References Instructor(TID)
  ,Constraint Enroll_SID_FK Foreign Key(SID) References Student(SID)
  ,Constraint Enroll_Class_Name_FK Foreign Key(Class_Name) References Class(Name)
        ,Constraint CHK_PMT CHECK (Payment <= 100.00 and Payment >= 10.00) --change
);

CREATE TABLE Log_Refund_Yoga
(
Refund_Log INT
,SID INT
,Payment number(6,2)
,Constraint RLOG_PK Primary Key (Refund_Log)
 -- ,Constraint RLOG_FK Foreign key(Payment) references Enroll(Payment)
,Constraint RLOG_FK Foreign key(SID) references Student(SID)
);

CREATE SEQUENCE Log_Refund_seq
MINVALUE        -1
START WITH      0;

CREATE SEQUENCE Log_seq
MINVALUE        -1
START WITH      0;

--Codys part
CREATE OR REPLACE TRIGGER expLevel_Trigger
        BEFORE INSERT ON Enroll
        FOR EACH ROW
        DECLARE
        v_class Class.Class_Level%TYPE;
        v_student_level Student.Exp_Level%TYPE;
        class_level_int Int;
        student_level_int Int;
        begin
        --Getting our class level and student level
        select Class_Level into v_class
        FROM Class
        WHERE Class.Name = :NEW.Class_name;

        select Exp_Level into v_student_level
        FROM Student
        WHERE Student.SID = :NEW.SID;

        if v_class = 'B' then
                class_level_int := 1;
        elsif v_class = 'I' then
                class_level_int := 2;
        elsif v_class = 'A' then
                class_level_int := 3;
        elsif v_class = 'E' then
                class_level_int := 4;
        else
                dbms_output.put_line('Could not get integer value for class');
        end if;

        if v_student_level = 'B' then
                student_level_int := 1;
        elsif v_student_level = 'I' then
                student_level_int := 2;
        elsif v_student_level = 'A' then
                student_level_int := 3;
        elsif v_student_level = 'E' then
                student_level_int := 4;
        else
                dbms_output.put_line('Could not get integer value for student');
        end if;

        if student_level_int < class_level_int then
                raise_application_error(-20001,'Student does not have enough experience for class');
        end if;
        end expLevel_Trigger;
        /
        SHOW ERRORS;

        --Codys part
        CREATE OR REPLACE TRIGGER highAttend_Trigger
        AFTER INSERT ON Enroll
        FOR EACH ROW
        DECLARE
                v_class_count Class.classCount%TYPE;
        BEGIN
                select Class.classCount into v_class_count
                FROM Class
                Where Name = :NEW.Class_Name;
                --Adding one to whatever class was selected
                v_class_count := v_class_count + 1;

                UPDATE CLASS
                SET classCount = v_class_count
                WHERE Class.Name = :NEW.Class_Name;

        end highAttend_Trigger;
        /
        SHOW ERRORS;

        CREATE OR REPLACE TRIGGER log_Yoga_Refund_Trigger
        AFTER DELETE ON Enroll
        FOR EACH ROW
--      DECLARE
--      v_SID Enroll.SID%TYPE;
--      v_payment Enroll.Payment%TYPE;
        BEGIN

        INSERT INTO Log_Refund_Yoga(Refund_Log,SID,Payment)
        VALUES(Log_Refund_seq.nextval,:OLD.SID,:OLD.Payment);

        end log_Yoga_Refund_Trigger;
        /
        SHOW ERRORS;


Insert into Instructor(TID,Fname,Lname,City, State, Rate_hour)
values (1,'Sally', 'Greenville','Radford', 'VA', 40.00);
Insert into Instructor values(2,'John','Wooding','Blacksburg','VA',60.00);
Insert into Instructor values(3,'Debbie','Delfield','Roanoke','VA',45.00);
Insert into Instructor values(4,'Elaine','Tobies','Radford','VA',50.00);

INSERT INTO Student(SID,First,Last,Exp_Level,City, State)
values(101,'Sally','Treville','E','Salem','VA');
INSERT INTO Student values(102,'Gerald','Warner','B','Roanoke','VA');
INSERT INTO Student values(104,'Katie','Johnson','B','Blacksburg','VA');
INSERT INTO Student values(105,'Matt','Kingston','E','Radford','VA');
INSERT INTO Student values(106,'Ellen','Maples','I','Radford','VA');
INSERT INTO Student values(108,'Tom','Rivers','E','Radford','VA');
INSERT INTO Student values(109,'Barbara','Singleton','E','Radford','VA');
INSERT INTO Student values(110,'Jonathan','Stiner','I','Salem','VA');


-- Class Table Inserts
INSERT INTO Class (Name,Duration,Class_Level,TID, Day, Time, Cost,classCount)
        Values ('Fun with Yoga', 60, 'B', 1, 'Mon', '6:00 PM', 15.00,0);
INSERT INTO Class       Values ('Stretch Yoga', 90, 'I', 2, 'Tues', '5:30 PM', 20.00,0);
INSERT INTO Class       Values ('Lunch Yoga', 50, 'A', 3, 'Wed', '12:30 PM', 15.00,0);
INSERT INTO Class       Values ('Yoga for All', 90, 'A', 4, 'Thurs', '7:00 PM', 25.00,0);
INSERT INTO Class       Values ('Yoga Inversions', 60, 'I', 1, 'Sat', '10:00 PM', 20.00,0);
INSERT INTO Class       Values ('Advanced Yoga', 90, 'E', 4, 'Sat', '2:00 PM', 25.00,0);
INSERT INTO Class       Values ('Relaxation Yoga', 90, 'I', 4, 'Mon', '7:30 PM', 40.00,0);

-- Enroll Table Inserts and testing highAttend Trigger
INSERT INTO Enroll (Class_Name, TID, SID, Payment)
        Values ('Fun with Yoga', 1, 102, 15.00);
INSERT INTO Enroll      Values ('Fun with Yoga', 1, 104, 15.00);
INSERT INTO Enroll      Values ('Fun with Yoga', 1, 108, 15.00);
INSERT INTO Enroll      Values ('Stretch Yoga', 2, 106, 20.00);
INSERT INTO Enroll      Values ('Stretch Yoga', 2, 108, 20.00);
INSERT INTO Enroll      Values ('Lunch Yoga', 3, 102, 15.00);
INSERT INTO Enroll      Values ('Lunch Yoga', 3, 109, 15.00);
INSERT INTO Enroll      Values ('Yoga for All', 4, 106, 10.00);
INSERT INTO Enroll      Values ('Yoga for All', 4, 108, 25.00);
INSERT INTO Enroll      Values ('Yoga Inversions', 1, 106, 25.00);
INSERT INTO Enroll      Values ('Yoga Inversions', 1, 105, 25.00);
INSERT INTO Enroll      Values ('Advanced Yoga', 4, 106, 25.00);
INSERT INTO Enroll      Values ('Advanced Yoga', 4, 108, 25.00);
INSERT INTO Enroll      Values ('Stretch Yoga', 2, 110, 20.00);
INSERT INTO Enroll      Values ('Relaxation Yoga', 4, 101, 10.00);
INSERT INTO Enroll      Values ('Relaxation Yoga', 4, 106, 10.00);
INSERT INTO Enroll      Values ('Relaxation Yoga', 4, 108, 10.00);
COMMIT;
select * from class;
--Testing log Refund
select * from log_refund_yoga;
DELETE FROM Enroll
WHERE Class_name = 'Fun with Yoga';
select * from log_refund_yoga;

DELETE FROM Enroll
WHERE SID = 106;
select * from log_refund_yoga;
ROLLBACK;
