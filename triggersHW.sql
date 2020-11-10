--Cody Claxton
DROP Trigger Loan_Trigger;
CREATE OR REPLACE TRIGGER Loan_Trigger
    AFTER UPDATE of Fees ON Loan
        FOR EACH ROW
        WHEN (NEW.Fees>=100.00)
DECLARE
        v_book_id Loan.Book_Id%TYPE;
    v_member_id Loan.Member_Id%TYPE;
    v_fees Loan.Fees%TYPE;
begin
        v_book_id := :old.Book_Id;
        v_member_id := :old.Member_Id;
        v_fees := :new.Fees;
                        IF (:OLD.Fees < 100) then
                        INSERT INTO Debt(Debt_Id,Book_Id,Member_Id,Amt_Owed,Record_Date)
                                VALUES(Debt_seq.NEXTVAL,v_book_id, v_member_id,v_fees,SYSDATE);
                --Still need to delete from loan table
                        end if;
    END Loan_Trigger;
    /
SHOW ERRORS;



DROP TRIGGER expLevel_Trigger
CREATE OR REPLACE TRIGGER expLevel_Trigger
        BEFORE INSERT ON Enrollments
        FOR EACH ROW
        DECLARE
        v_class Enroll.class_name%TYPE;
        v_student_id Enroll.SID%TYPE;
        class_level_int Int;
        student_level_int Int;
        begin
        v_class := :new.Class_name;
        v_student_id := :new.SID;


        --Joining our tables
        SELECT Class.Class_Level, Student.Exp_Level
        From Class c
        INNER JOIN Enroll e ON c.Name = e.Class_Name
        INNER JOIN Student s ON e.SID = s.SID
        WHERE Class = v_class AND Student.SID = v_student_Id;

        --Case statement to convert to integers
        if v_class.Class_Level = 'B' then
                class_level_int := 1;
        else if v_class.Class_Level = 'I' then
                class_level_int := 2;
        else if v_class.Class_Level = 'A' then
                class_level_int := 3;
        else if v_class.Class_level = 'E' then
                class_level_int := 4;
        else
                RAISE_APPLICATION_ERROR(-20020, "No matching class level");
        end if;

        if v_student_id.Exp_level = 'B' then
                student_level_int := 1;
        else if v_student_id.Exp_level = 'I' then
                student_level_int := 2;
        else if v_student_id.Exp_level = 'A' then
                student_level_int := 3;
        else if v_student_id.Exp_level = 'E' then
                student_level_int := 4;
        else
                RAISE_APPLICATION_ERROR(-20020, "No matching student experience level");
        end if;

        if student_level_int >= class_level then
                INSERT INTO Enroll(Class_Name,TID,SID,Payment)
                VALUES(:NEW.Class_name,:NEW.TID,:NEW.SID, :NEW.Payment);
        else
                RAISE_APPLICATION_ERROR(-20021,"Student does not have enough experience for class");
        end if;

        end expLevel_Trigger;
        /
        SHOW ERRORS;
