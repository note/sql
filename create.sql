create database OurRental
use OurRental
CREATE TABLE label (
  labelID int NOT NULL PRIMARY KEY IDENTITY,
  priceMultiply DECIMAL(2) NOT NULL DEFAULT 1,
  loanPeriod int NULLda
)
CREATE TABLE member (
  memberID int NOT NULL PRIMARY KEY IDENTITY,
  lastname VARCHAR(50) NOT NULL,
  firstname VARCHAR(50) NOT NULL,
  phone CHAR(11) NOT NULL,
  email VARCHAR(100) NULL,
  active BIT NULL,
  CONSTRAINT ck_phone CHECK(LEN(phone) = 11)
)

CREATE TABLE medium (
  mediumID int NOT NULL PRIMARY KEY IDENTITY,
  mediumName VARCHAR(20) NOT NULL,
  priceMultiply DECIMAL(2) NOT NULL DEFAULT 1,
  CONSTRAINT medium_index UNIQUE (mediumName)
)

CREATE TABLE film (
  filmID int NOT NULL PRIMARY KEY IDENTITY,
  filmPrice DECIMAL(2) NOT NULL,
  title VARCHAR(80) NOT NULL,
  director VARCHAR(80) NOT NULL,
  description TEXT NULL
)
CREATE INDEX titleIndex ON film(title) 


CREATE TABLE category (
  categoryID int NOT NULL PRIMARY KEY IDENTITY,
  categoryName VARCHAR(30) NOT NULL,
  CONSTRAINT category_index UNIQUE (categoryName)
)

CREATE TABLE adult (
  memberID int NOT NULL PRIMARY KEY,
  street VARCHAR(50) NOT NULL,
  homeNo VARCHAR(6) NOT NULL,
  flatNo VARCHAR(6) NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(50) NOT NULL,
  zip CHAR(5) NOT NULL,
  expirationDate DATE NOT NULL,
  FOREIGN KEY (memberID) references member(memberID),
  CONSTRAINT ck_expirationDate CHECK(expirationDate>GETDATE()),
  CONSTRAINT ck_zip CHECK(LEN(zip) = 5)
)

CREATE TABLE film_and_label (
  filmID int NOT NULL,
  labelID int NOT NULL,
  expirationDate DATE NULL,
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (labelID) references label(labelID),
  PRIMARY KEY(filmID, labelID),
  CHECK (expirationDate>GETDATE())
)

CREATE TABLE film_and_category (
  filmID int NOT NULL,
  categoryID int NOT NULL,
  FOREIGN KEY (filmID) references film(filmID) ON DELETE CASCADE,
  FOREIGN KEY (categoryID) references category(categoryID) ON DELETE CASCADE,
  PRIMARY KEY(filmID, categoryID)
)

CREATE TABLE item (
  filmID int NOT NULL,
  mediumID int NOT NULL,
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (mediumID) references medium(mediumID),
  PRIMARY KEY(filmID, mediumID)
)
CREATE TABLE juvenile (
  memberID int NOT NULL PRIMARY KEY,
  adult_memberID int NOT NULL,
  birthDate DATE NOT NULL,
  FOREIGN KEY (memberID) references member(memberID) on delete cascade,
  FOREIGN KEY (adult_memberID) references adult(memberID),
  CONSTRAINT ck_birthDate CHECK (birthDate > (year(getdate()) - 18) and birthDate < GETDATE()) 
 )

CREATE TABLE copy (
  copyID int NOT NULL PRIMARY KEY IDENTITY,
  mediumID int NOT NULL,
  filmID int NOT NULL,
  onLoan BIT NOT NULL,
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (mediumID) references medium(mediumID)
)

CREATE TABLE reservation (
  memberID int NOT NULL,
  mediumID int NOT NULL,
  filmID int NOT NULL,
  logDate DATE NOT NULL default getdate(),
  acceptDate DATE NULL,
  FOREIGN KEY (memberID) references member(memberID),
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (mediumID) references medium(mediumID),
  PRIMARY KEY (memberID, mediumID, filmID),
  CONSTRAINT ck_logDate CHECK(logDate=GETDATE()),
  CHECK (acceptDate >= logDate)
)

CREATE TABLE loan (
  copyID int NOT NULL PRIMARY KEY,
  memberID int NOT NULL,
  outDate DATE NOT NULL default getdate(),
  dueDate DATE NOT NULL,
  FOREIGN KEY (copyID) references copy(copyID),
  FOREIGN KEY (memberID) references member(memberID),
  CONSTRAINT ck_outDate CHECK(logDate=GETDATE()),
  CHECK (dueDate>outDate)
)

CREATE TABLE loanhist (
  outDate DATE NOT NULL,
  copyID int NOT NULL,
  memberID int NOT NULL,
  dueDate DATE NOT NULL,
  inDate DATE NOT NULL default getdate(),
  fineAssessed DECIMAL(2) NULL,
  finePaid DECIMAL(2) NULL,
  fineWaived DECIMAL(2) NULL,
  remarks TEXT NULL,
  FOREIGN KEY (copyID) references copy(copyID),
  FOREIGN KEY (memberID) references member(memberID),
  PRIMARY KEY (outDate, copyID),
  CONSTRAINT ck_inDate CHECK(logDate=GETDATE()),
  CHECK (finePaid <= fineAssessed-fineWaived)
)


CREATE TABLE reservation_and_film_and_label (
  memberID int NOT NULL,
  labelID int NOT NULL,
  filmID int NOT NULL,
  mediumID int NOT NULL,
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (labelID) references label(labelID),
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (memberID) references member(memberID),
  FOREIGN KEY (mediumID) references medium(mediumID)
)

create procedure deleteMember @id int
as
begin
	delete from member where memberID in (select memberID from juvenile where adult_memberID=@id)
	delete from adult where memberID=@id
	delete from member where memberID=@id
end

-- Returns discount in percentage. If loan can't be insterted then returns -1.
create procedure insertLoan @copy_id int, @member_id int, @discount int OUTPUT
as
begin
	declare @rowcount int
	set @discount=0
	select @rowcount=COUNT(*) from loan where memberID=@member_id
	if(@rowcount<6)
		begin
		select @rowcount=COUNT(*) from loanhist where memberID=@member_id
		
		if(@rowcount>3)
			begin
			set @discount=10
			end
			
		insert into loan (copyID, memberID, outDate, dueDate) Values (@copy_id, @member_id, GETDATE(), GETDATE()+4)
		end
	else
		begin
		set @discount=-1
		PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + ' ma juz wypozyczonych 6 filmow'
		end
end

/*create TRIGGER tr_insterLoan
on loan
INSTEAD OF INSERT
AS
begin
	PRINT 'Aby dodac wypozyczenie (loan) skorzystaj z procedury insertLoan'
end

-- proponuje taka konwencje dla nazw triggerow
CREATE TRIGGER tr_deleteMember
ON member
INSTEAD OF DELETE
AS
begin
	PRINT 'Aby usunac uzytkownika skorzystaj z prodecury deleteMember'
end

CREATE TRIGGER tr_deleteAdult
ON adult
INSTEAD OF DELETE
AS
begin
	PRINT 'Aby usunac uzytkownika skorzystaj z prodecury deleteMember'
end*/

CREATE TRIGGER tr_insertJuvenile
on juvenile
after insert
as
begin
	IF DATEDIFF(YEAR, (select birthDate from inserted),  GETDATE())>18  --wazne zalozenie - jak ukonczy rocznikowo 18 lat to uznajemy, ze jest pelnoletni'
	begin
		UPDATE member SET active=0 WHERE memberID=(SELECT memberID from inserted)
	end
end

CREATE TRIGGER tr_updateJuvenile
on juvenile
after update
as
begin
	IF DATEDIFF(YEAR, (SELECT birthDate from inserted),  GETDATE())>18  --wazne zalozenie - jak ukonczy rocznikowo 18 lat to uznajemy, ze jest pelnoletni'
	begin
		UPDATE member SET active=0 WHERE memberID=(SELECT memberID from inserted)
	end
end

CREATE TRIGGER tr_deleteLoan
ON loan
AFTER DELETE
AS BEGIN
	INSERT INTO loanhist (outDate, copyID, memberID, dueDate) VALUES ((SELECT outDate from deleted), (SELECT copyID from deleted), (SELECT memberID from deleted), (SELECT dueDate from deleted)) --todo naliczanie kary
END
