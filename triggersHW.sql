--Cody Claxton
--DB1
--HW 9

SET ECHO ON;
SET serveroutput ON;
DROP Trigger Loan_Trigger;
Drop Table Debt;
Drop Table Loan;
Drop Sequence Debt_seq;

CREATE SEQUENCE Debt_seq
        MINVALUE 0
        START WITH 0
        INCREMENT BY 1;


CREATE TABLE Loan
(
        Book_Id                 char(10)
    ,Member_Id          integer
        ,Fees                   Decimal(5,2)
        ,CONSTRAINT PKBook PRIMARY KEY(Book_Id)
);

CREATE TABLE Debt
(
        Debt_ID                         integer
        ,Book_ID                        char(10)
        ,Member_ID                      integer
        ,Amt_Owed                       Decimal(5,2)
        ,Record_date        Date
        ,CONSTRAINT FKBook_id FOREIGN KEY(Book_id) references Loan
        ,CONSTRAINT Fees_CK CHECK(Amt_Owed >= 100.00)
        --Probably will need a trigger here to check in fees table
        ,CONSTRAINT PKDebt PRIMARY KEY(Debt_ID)
);

INSERT INTO Loan(Book_Id,Member_Id,Fees)
VALUES(12345, 1,20.00);

INSERT INTO Loan(Book_Id,Member_Id,Fees)
VALUES(98765, 2,0.00);

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
            end if;
END Loan_Trigger;
        /

UPDATE Loan
SET Fees = 75.00
Where Member_Id = 1;

UPDATE Loan
SET Fees = 108.00
WHERE Member_Id = 1;

UPDATE Loan
SET Fees = 120.00
WHERE Member_id = 1;
/

SHOW ERRORS;
