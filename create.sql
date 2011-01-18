--create database OurRental
use OurRental
CREATE TABLE label (
  labelID int NOT NULL PRIMARY KEY IDENTITY,
  priceMultiply DECIMAL(2) NOT NULL DEFAULT 1,
  loanPeriod int NULL
)
CREATE TABLE member (
  memberID int NOT NULL PRIMARY KEY IDENTITY,
  lastname VARCHAR(50) NOT NULL,
  firstname VARCHAR(50) NOT NULL,
  phone VARCHAR(11) NOT NULL,
  email VARCHAR(100) NULL,
  active BIT NULL
)

CREATE TABLE medium (
  mediumID int NOT NULL PRIMARY KEY IDENTITY,
  mediumName VARCHAR(20) NOT NULL,
  priceMultiply DECIMAL(2) NOT NULL DEFAULT 1,
  CONSTRAINT medium_index UNIQUE (mediumName)
)

CREATE TABLE film (
  filmID int NOT NULL PRIMARY KEY IDENTITY,
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
  zip TEXT NOT NULL,
  expirationDate DATE NOT NULL,
  FOREIGN KEY (memberID) references member(memberID)
)

CREATE TABLE film_and_label (
  filmID int NOT NULL,
  labelID int NOT NULL,
  expirationDate DATE NULL,
  FOREIGN KEY (filmID) references film(filmID),
  FOREIGN KEY (labelID) references label(labelID),
  PRIMARY KEY(filmID, labelID)
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
  FOREIGN KEY (adult_memberID) references adult(memberID)
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
  PRIMARY KEY (memberID, mediumID, filmID)
)

CREATE TABLE loan (
  copyID int NOT NULL PRIMARY KEY,
  memberID int NOT NULL,
  outDate DATE NOT NULL default getdate(),
  dueDate DATE NOT NULL,
  FOREIGN KEY (copyID) references copy(copyID),
  FOREIGN KEY (memberID) references member(memberID)
)

CREATE TABLE loanhist (
  outDate DATE NOT NULL,
  copyID int NOT NULL,
  dueDate DATE NOT NULL,
  inDate DATE NOT NULL default getdate(),
  fineAssessed DECIMAL(2) NULL,
  finePaid DECIMAL(2) NULL,
  fineWaived DECIMAL(2) NULL,
  remarks TEXT NULL,
  FOREIGN KEY (copyID) references copy(copyID),
  PRIMARY KEY (outDate, copyID)
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

/*
create procedure deleteMember @id int
as
begin
	delete from member where memberID in (select memberID from juvenile where adult_memberID=@id)
	delete from adult where memberID=@id
	delete from member where memberID=@id
end
*/