create database OurRental
--drop database OurRental

use OurRental
create TABLE label (
	labelID int NOT NULL PRIMARY KEY IDENTITY,
	labelName VARCHAR(20) NOT NULL,
	priceMultiply DECIMAL(18,2) NOT NULL DEFAULT 1,
	CONSTRAINT label_unique UNIQUE (labelName)
)
CREATE TABLE member (
	memberID int NOT NULL PRIMARY KEY IDENTITY,
	lastname VARCHAR(50) NOT NULL,
	firstname VARCHAR(50) NOT NULL,
	birthDate DATE NOT NULL,
	phone CHAR(11) NOT NULL,
	email VARCHAR(100) NULL,
	active BIT NULL default 1,
	CONSTRAINT ck_phone CHECK(LEN(phone) = 11),
	CHECK (birthDate < getdate()),
	CHECK (year(birthDate) > 1900),
	CONSTRAINT memberUQ UNIQUE (firstname, lastname, birthdate, active)
)

CREATE TABLE medium (
	mediumID int NOT NULL PRIMARY KEY IDENTITY,
	mediumName VARCHAR(20) NOT NULL,
	priceMultiply DECIMAL(18,2) NOT NULL DEFAULT 1,
	CONSTRAINT medium_index UNIQUE (mediumName)
)

CREATE TABLE film (
	filmID int NOT NULL PRIMARY KEY IDENTITY,
	filmPrice DECIMAL(18,2) NOT NULL,
	title VARCHAR(80) NOT NULL,
	director VARCHAR(80) NOT NULL,
	description TEXT NULL
	CONSTRAINT UQ_film UNIQUE (director, title)
)

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
	FOREIGN KEY (memberID) references member(memberID),
	CONSTRAINT ck_zip CHECK(LEN(zip) = 5)
)

CREATE TABLE film_and_label (
	filmID int NOT NULL,
	labelID int NOT NULL,
	expirationDate DATE NULL,
	FOREIGN KEY (filmID) references film(filmID),
	FOREIGN KEY (labelID) references label(labelID),
	PRIMARY KEY(filmID, labelID),
	CHECK (expirationDate>GETDATE()),
	CONSTRAINT FL_unique UNIQUE (filmID, labelID)
)

CREATE TABLE film_and_category (
	filmID int NOT NULL,
	categoryID int NOT NULL,
	FOREIGN KEY (filmID) references film(filmID) ON DELETE CASCADE,
	FOREIGN KEY (categoryID) references category(categoryID) ON DELETE CASCADE,
	PRIMARY KEY(filmID, categoryID),
	CONSTRAINT FC_unique UNIQUE (filmID, categoryID)
)

CREATE TABLE item (
	filmID int NOT NULL,
	mediumID int NOT NULL,
	FOREIGN KEY (filmID) references film(filmID),
	FOREIGN KEY (mediumID) references medium(mediumID),
	PRIMARY KEY(filmID, mediumID),
	CONSTRAINT item_unique UNIQUE (filmID, mediumID)
)
CREATE TABLE juvenile (
	memberID int NOT NULL PRIMARY KEY,
	adult_memberID int NOT NULL,
	FOREIGN KEY (memberID) references member(memberID) on delete cascade,
	FOREIGN KEY (adult_memberID) references adult(memberID),
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
	copyID int null,
	FOREIGN KEY (copyID) references copy(copyID),
	FOREIGN KEY (memberID) references member(memberID),
	FOREIGN KEY (filmID) references film(filmID),
	FOREIGN KEY (mediumID) references medium(mediumID),
	PRIMARY KEY (memberID, mediumID, filmID),
	CHECK (acceptDate >= logDate),
	CONSTRAINT reservation_unique UNIQUE (memberID, mediumID, filmID),
	constraint reservation_unique1 unique (copyID)
)

CREATE TABLE loan (
	copyID int NOT NULL PRIMARY KEY,
	memberID int NOT NULL,
	outDate DATE NOT NULL default getdate(),
	dueDate DATE NOT NULL,
	FOREIGN KEY (copyID) references copy(copyID),
	FOREIGN KEY (memberID) references member(memberID),
	CHECK (dueDate>outDate),
	CONSTRAINT loan_unique UNIQUE (memberID, copyID)
)

CREATE TABLE loanhist (
	outDate DATE NOT NULL,
	copyID int NOT NULL,
	memberID int NOT NULL,
	dueDate DATE NOT NULL,
	inDate DATE NOT NULL default getdate(),
	fineAssessed DECIMAL(18,2) NULL,
	finePaid DECIMAL(18,2) NULL,
	fineWaived DECIMAL(18,2) NULL,
	remarks TEXT NULL,
	FOREIGN KEY (copyID) references copy(copyID),
	FOREIGN KEY (memberID) references member(memberID),
	PRIMARY KEY (outDate, copyID),
	CHECK (finePaid <= fineAssessed-fineWaived),
	CONSTRAINT loanhist_unique UNIQUE (outDate, copyID)
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
