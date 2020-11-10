--Cody Claxton
--My HW4 view assignment
--I set linesize to 200 so I could visualize my data better.
set linesize 200
--Question 1, creating our base view
DROP VIEW Ski_Club_LV;
CREATE VIEW Ski_Club_LV as
select t.TID,t.Resort,t.Sun_Date
,st.MID, st.First,st.Last,st.Exp_Level,st.Gender
,cr.RID, cr.Name, cr.Unit_no, cr.Bldg
,Deposit
FROM Trip t INNER JOIN Condo_Reservation cr
ON t.TID = cr.TID INNER JOIN Condo_Assign ca
ON cr.RID = ca.RID INNER JOIN SkiTeam st
On ca.MID = st.MID;
--Question 2, write a query from our base query
select name, COUNT(Deposit) as Skier_Count
From Ski_Club_LV
Group By name;
--Question 3, write a query from our base query
select Resort, Name, Bldg, Unit_NO, First,Last
From Ski_Club_LV
Order By Resort,Name;
--Question 4, creating a view for Lake Tahoo
DROP VIEW Lake_Tahoo_Skiers_LV;
CREATE VIEW Lake_Tahoo_Skiers_LV as
select Resort,First,Last,Exp_Level,st.Gender,Deposit,Name,Unit_No,Bldg,Sun_Date
From Trip t INNER JOIN Condo_Reservation cr
ON t.TID = cr.TID
INNER JOIN Condo_assign ca
ON cr.RID = ca.RID
INNER JOIN SkiTeam st
ON ca.MID = st.MID
WHERE City = 'Lake Tahoo' AND st.MID < 600 AND Sun_Date LIKE '%18';
--Question 5 Creating a query from our Lake Tahoo View
select First, Last, Name, Bldg,Unit_No
From Lake_Tahoo_Skiers_LV
Where Sun_Date LIKE '04%' AND Gender = 'F'
ORDER BY Last asc;
--Question 6 creating a query from our Lake Tahoo View
SELECT First,Last, Resort, 100 - Deposit AS AmountOwed
From Lake_Tahoo_Skiers_LV
ORDER BY Resort, AmountOwed desc;
