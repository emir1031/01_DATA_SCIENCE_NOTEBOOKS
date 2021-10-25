---------- 2021-08-16 DBMD Session 3 (DDL-DML) ----------------------


---- Create Database

CREATE DATABASE Library1;

USE Library1;

--- create schemas

CREATE SCHEMA Books;

CREATE SCHEMA Person;

--- creating table

--- create books.book table

CREATE TABLE [Books].[Book](
							Book_ID int PRIMARY KEY NOT NULL,
							Book_Name nvarchar(50) NULL
							);


--create Books.Author table

CREATE TABLE [Books].[Author](
							  [Author_ID] [int],
							  [Author_Name] [nvarchar](50) NULL
							  );

--create Books.Book_Author table

CREATE TABLE Books.Book_Author (
								Book_ID INT PRIMARY KEY,
								Author_ID INT NOT NULL
								);


--create Publisher Table

CREATE TABLE [Books].[Publisher](
								 [Publisher_ID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
								 [Publisher_Name] [nvarchar](100) NULL
								 );


--create Books_Publisher table
CREATE TABLE [Books].[Book_Publisher](
									  [Book_ID] [int] PRIMARY KEY NOT NULL,
									  [Publisher_ID] [int] NOT NULL
									  );


--create Person.Person table

CREATE TABLE [Person].[Person] (
								[Person_ID] [bigint] PRIMARY KEY NOT NULL,
								[Person_Name] [nvarchar](50) NULL,
								[Person_Surname] [nvarchar](50) NULL
								);


--create Person.Person_Book table

CREATE TABLE [Person].[Person_Book](
									[Person_ID] [bigint] NOT NULL,
									[Book_ID] [int] NOT NULL
									);


---create Person_Mail table

CREATE TABLE [Person].[Person_Mail](
									[Mail_ID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL, -- person id yapmadık çünkü bir kişinin birden fazla maili olabilir.
									[E_Mail] [text] NOT NULL,
									[Person_ID] [bigint] NOT NULL 
									);

--cretae Person.Person_Phone table

CREATE TABLE [Person].[Person_Phone](
									 [Phone_Number] [bigint] PRIMARY KEY NOT NULL,
									 [Person_ID] [bigint] NOT NULL	
									 );


-----  First create the tables as above and continue.
-----  Below we will show the DML commands and then define the table constraints.
-----  We will delete the data we added as an example later.


----INSERT

--- Data must be entered in accordance with the characteristics and limitations of the relevant column.


--- You can specify the table columns you will insert in parentheses as follows.
--- In this use, you only need to enter values ​​for the columns you specify. Column order is important.

INSERT INTO Person.Person (Person_ID, Person_Name, Person_Surname) 
VALUES (75056659595,'Zehra', 'Tekin')

SELECT * 
FROM Person.Person

INSERT INTO Person.Person (Person_ID, Person_Name) 
VALUES (889623212466,'Kerem')  -- Person surname can be null, so it won't return error

SELECT * 
FROM Person.Person

--- If you are not going to insert all columns in a table, the columns other than the one you selected must be Nullable.
--- It throws an error if there is a column with the Not Null constraint applied.

--- No value has been entered in the Person_Surname column below.
--- Since the Person_Surname column is Nullable, it completes the process by assigning a Null value instead of Person_Surname.



-- If the values ​​I will insert do not comply with the table constraints and column data types, it will not perform the operation.


--- You don't have to use INTO after INSERT keyword.
--- Also, you may not specify the columns you want to insert as below.
--- However, you should pay attention to the column order and the rules above.
--- In this use, it is assumed to insert all columns of the table and asks you for values ​​for all columns.

INSERT Person.Person 
VALUES (15078893526,'Mert','Yetis')

SELECT * 
FROM Person.Person

--- If there are columns of unknown value, you can write Null instead.
--- these columns that you want to write Null must be Nullable.

INSERT Person.Person 
VALUES (55556698752, 'Esra', Null)

SELECT * 
FROM Person.Person



----If you want to insert many records into the same columns of the same table, you can use the following syntax.
--- Another issue you should pay attention to here is that no value is assigned to the Mail_ID column.
--- The Mail_ID column contains auto-incrementing values ​​because it is defined as identity when creating the table.
--- Inserting a value into an auto-incrementing column is not allowed.

INSERT INTO Person.Person_Mail (E_Mail, Person_ID) -- Mail_ID column consists IDENTITY, we can't assign anything into it
VALUES 	('zehtek@gmail.com', 75056659595),
	    ('meyet@gmail.com', 15078893526),
	    ('metsak@gmail.com', 35532558963);
		
SELECT * 
FROM Person.Person_Mail;

--- When you run the following functions with the above syntax
--- In the last insert operation, they return the identity of the last record added to the table and the number of affected records in the table.

SELECT @@ROWCOUNT ---- last process row count
SELECT @@IDENTITY ---- last process last identity number



----- With the following syntax, you can insert values ​​from a different table into a different table that you have created before.
---- Column order, type, constraints and other rules are also important.

SELECT * INTO Person.Person_2 
FROM Person.Person

SELECT * 
FROM Person.Person

SELECT * 
FROM Person.Person_2


INSERT Person.Person_2 (Person_ID, Person_Name, Person_Surname)
SELECT * 
FROM Person.Person 
WHERE Person_name like 'M%'  -- Mert and Metin


SELECT * 
FROM Person.Person_2



----As you can see in the syntax below, no value is specified.
---- In this way, the table will be inserted into the table with the default values ​​of the table.
--- the column constraints must be conducive to this.

INSERT Books.Publisher
DEFAULT VALUES

SELECT * 
FROM Books.Publisher

---------- 2021-08-16 DBMD Session 3 (DDL-DML) ***END*** ----------------------

--- Update

---- Pay attention to defining conditions in the Update process. If you do not define any conditions
---- The change will be applied to all values ​​in the column.

UPDATE Person.Person_2 SET Person_Name = 'Default_Name'

SELECT * 
FROM Person.Person_2

---- we give the condition with Where 
--- we change the person_name

UPDATE Person.Person_2 
SET Person_Name = 'Can' 
WHERE Person_ID = 15078893526



--- update with join

UPDATE Person.Person_2 SET Person_Name = B.Person_Name 
FROM Person.Person_2 A Inner Join Person.Person B ON A.Person_ID=B.Person_ID
WHERE B.Person_ID = 55556698752

SELECT * 
FROM Person.Person_2

--- update with subquery

UPDATE Person.Person_2 SET Person_Name = 
		(SELECT Person_Name FROM Person.Person where Person_ID = 75056659595) 
WHERE Person_ID = 75056659595

SELECT * 
FROM Person.Person_2


--- delete

----In the use of Delete, when you add a new record to a table whose data you deleted with Delete,
--- If your table has an auto-incrementing identity column, the identity of the new record added
---  it will continue after the identity of the last deleted record.

INSERT Books.Publisher 
VALUES ('is Bankasi Kültür Yayinlari'), ('Can Yayinlari'), ('iletisim Yayinlari')

--- With Delete, the Book.Publisher table is emptied again.
DELETE FROM Books.Publisher 

---- control
SELECT * 
FROM Books.Publisher

---- Inserting a new data into the Book.Publisher table
INSERT Books.Publisher 
VALUES ('Paris')

---- When we check again, it will be seen that the identity of the newly inserted record continues as usual in the old table.
SELECT * 
FROM Books.Publisher

----///////////////////////
----- /////////////////////

--- after here we will do it examples about constraints and alter table
--- In order for the operations we will do to be consistent, let's first empty our tables in which we have inserted data above as an example.

--- drop

DROP TABLE Person.Person_2; ----- no need anymore

TRUNCATE TABLE Person.Person_Mail;
TRUNCATE TABLE Person.Person;
TRUNCATE TABLE Books.Publisher;


-- alter table

--- Let's copy the table first
SELECT Person_Name, Person_Surname 
INTO Sample_Person 
FROM Person.Person

--- then let's change the name of the newly created table
SP_Rename 'dbo.Sample_Person', 'Person_New'

---- Then let's rename the Person_Name Column of this table using the new name of the table
sp_rename 'Person_New.Person_Name', 'First_Name', 'Column'



----- Book table has PK

----- Author table

--- we create PK for author table because when we created that table, we didn't assign any PK key.
--- you got the error here. you will need to make an edit to the table
--- I expect you to experience this and solve the problem. Otherwise, you will get an error in the next table as well. :)

ALTER TABLE Books.Author ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)
ALTER TABLE Books.Author ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)

ALTER TABLE Books.Author ALTER COLUMN Author_ID INT NOT NULL

----- We must add a foreign key constraint to the Book_Author table
ALTER TABLE Books.Book_Author 
ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Books.Author (Author_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION



ALTER TABLE Books.Book_Author 
ADD CONSTRAINT FK_Book2 FOREIGN KEY (Book_ID) REFERENCES Books.Book (Book_ID)
ON UPDATE NO ACTION
ON DELETE CASCADE

---- publisher table is normal


---- We must add a foreign key constraint to the Books_Publisher table
ALTER TABLE Books.Book_Publisher 
ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Books.Publisher (Publisher_ID)

ALTER TABLE Books.Book_Publisher 
ADD CONSTRAINT FK_Book FOREIGN KEY (Book_ID) REFERENCES Books.Book (Book_ID)


----- Let's add check constraint to the Person_ID column in the Person.Person table, since it must have 11 digits.
Alter table Person.Person 
add constraint FK_PersonID_check Check (Person_ID between 9999999999 and 99999999999)

SELECT *
FROM Person.Person;

---- Person_Book table

---- We need to add a Composite primary key to the Person_Book table.
---- Let's define a Foreign key constraint on two ID columns

Alter table Person.Person_Book add constraint PK_Person Primary Key (Person_ID,Book_ID)


Alter table Person.Person_Book add constraint FK_Person1 Foreign key (Person_ID) References Person.Person(Person_ID)

Alter table Person.Person_Book add constraint FK_Book1 Foreign key (Book_ID) References Books.Book(Book_ID)


----- Person.Person_Phone

---- We need to create a foreign key constraint for person_ID in the Person_Phone table.

Alter table Person.Person_Phone add constraint FK_Person3 Foreign key (Person_ID) References Person.Person(Person_ID)


---- Person.Person_Mail table

--- we have to define FK for Person.Person_Mail table

Alter table Person.Person_Mail add constraint FK_Person4 Foreign key (Person_ID) References Person.Person(Person_ID)



----At this stage, I expect you to draw the database diagram and make sure that the connections between all tables are created.


--- I leave the insert operations to you, it is more valuable to do it by getting errors and experiencing what constraints mean for yourself.
--- I will also send the script that we worked on in the lesson about the index topic.
---- I leave a Mentoring weekly agenda note for you to create the indexes of the Tables here. You can work together or individually.


---- If you have any question, you can reach me via Slack
--- take care, have a good day :) 

/*
CREATE FUNCTION dbo.[KIMLIKNO_KONTROL](@TcNo Bigint)
RETURNS BIT
AS
BEGIN
      DECLARE @ATCNO Bigint
      DECLARE @BTCNO Bigint
      DECLARE @C1    Tinyint
      DECLARE @C2    Tinyint
      DECLARE @C3    Tinyint
      DECLARE @C4    Tinyint
      DECLARE @C5    Tinyint
      DECLARE @C6    Tinyint
      DECLARE @C7    Tinyint
      DECLARE @C8    Tinyint
      DECLARE @C9    Tinyint
      DECLARE @Q1    Int
      DECLARE @Q2    Int
      DECLARE @SONUC Bit
      SET @ATCNO = @TcNo / 100
      SET @BTCNO = @TcNo / 100
      IF LEN(CONVERT(VARCHAR(19),@TcNo)) = 11
      BEGIN
            SET @C1 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C2 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C3 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C4 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C5 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C6 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C7 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C8 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @C9 = @ATCNO % 10 SET @ATCNO = @ATCNO / 10
            SET @Q1 = ((10-((((@C1+@C3+@C5+@C7+@C9)*3)+(@C2+@C4+@C6+@C8)) % 10))%10)
            SET @Q2 = ((10-(((((@C2+@C4+@C6+@C8)+@Q1)*3)+(@C1+@C3+@C5+@C7+@C9))%10))%10)
            IF (@BTCNO * 100)+(@Q1 * 10)+@Q2 = @TcNo SET @SONUC = 1 ELSE SET @SONUC = 0
      END
      ELSE SET @SONUC = 0
RETURN @SONUC
END
*/

