/*	
 *	PROCEDURES
 */

create procedure deleteMember @id int
as
begin
	delete from member where memberID in (select memberID from juvenile where adult_memberID=@id)
	delete from adult where memberID=@id
	delete from member where memberID=@id
end

go

--Returns discount in percentage. If loan can't be insterted then returns -1.
--Also will not allow to make a loan for one who is keeping films too long
create procedure insertLoan @copy_id int, @member_id int, @discount int OUTPUT
as
begin
	declare @active int
	select @active = active from member where memberID = @member_id
	if(@active = 1) begin
		declare @rowcount int
		set @discount=0
		select @rowcount=COUNT(*) from loan where memberID=@member_id

		-- warunek na przetrzymywanie filmow:
		declare @time_delay int
		select @time_delay=count(*) from loan where memberID=@member_id and GETDATE() > outDate

		if(@rowcount<6) and (@time_delay = 0) begin
			select @rowcount=COUNT(*) from loanhist where memberID=@member_id and (DATEADD(dd, 92, outDate)) > getdate();
		
			if(@rowcount>=3) begin
				set @discount=10
			end
			
			insert into loan (copyID, memberID, outDate, dueDate) Values (@copy_id, @member_id, GETDATE(), GETDATE()+4)
		end
		else if(@rowcount >= 6) begin
			set @discount=-1
			PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + ' ma juz wypozyczonych 6 filmow'
		end
		else begin
			PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'przetrzymuje filmy'
		end
	end else PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'jest nieaktywny'
end

go

create procedure setMemberActive @member_id int, @active int
as
begin
	if(@active<>0 AND @active<>1) begin
		PRINT 'Drugi argument funkcji setMemberActive musi byc wartosci 0 lub 1'
	end
	else begin
		UPDATE member SET active=@active WHERE memberID=@member_id
	end
end

go

--will not allow to make a reservation for one who is keeping films too long
create procedure insertReservation @member_id int, @film_id int, @medium_id int
as
begin
	declare @active int
	select @active = active from member where memberID = @member_id
	if(@active = 1) begin
		declare @time_delay int
		select @time_delay=count(*) from loan where memberID=@member_id and GETDATE() > outDate
		if (@time_delay > 0) begin
			PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + ' przetrzymuje filmy'
		end
		else begin			
			insert into reservation (memberID, mediumID, filmID, logDate) Values (@member_id, @medium_id, @film_id, GETDATE())
		end
	end else PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'jest nieaktywny'
end

create procedure insertAdult @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @street varchar (50), @homeNo varchar (6), @flatNo varchar (6), @city varchar (50), @state varchar (50), @zip char(5)
as begin
	insert into view_members (firstname, lastname, phone, email, street, homeNo, flatNo, city, state, zip) values(@firstname, @lastname, @phone, @email, @street, @homeNo, @flatNo, @city, @state, @zip)
end
go

create procedure insertJuvenile @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @birthdate date, @adult_id int
as begin
	insert into view_members (firstname, lastname, phone, email, birthdate, adult_memberID) values(@firstname, @lastname, @phone, @email, @birthdate, @adult_id)
end
go

/*	
 *	TRIGGERS
 */

CREATE TRIGGER tr_deleteLoan
ON loan
AFTER DELETE
AS BEGIN
	INSERT INTO loanhist (outDate, copyID, memberID, dueDate) VALUES ((SELECT outDate from deleted), (SELECT copyID from deleted), (SELECT memberID from deleted), (SELECT dueDate from deleted)) --todo naliczanie kary
END

go

CREATE TRIGGER tr_updateMember
ON member
AFTER UPDATE
AS BEGIN
	UPDATE member SET active=(SELECT active from inserted) WHERE memberID = ANY(
		SELECT memberID from juvenile where adult_memberID=(select memberID from inserted)
	)
END

go

CREATE TRIGGER tr_insertViewMembers
on view_members
INSTEAD OF INSERT
AS BEGIN
	INSERT INTO member (lastname, firstname, phone, email) values ((select lastname from inserted), (select firstname from inserted), (select phone from inserted), (select email from inserted))
	declare @adult_id int
	SET @adult_id = (SELECT adultid from inserted)
	IF @adult_id is null begin
		INSERT INTO adult (memberID, street, homeNo, flatNo, city, state, zip) VALUES ((SELECT @@IDENTITY), (select street from inserted), (select homeNo from inserted), (select flatNo from inserted), (select city from inserted), (select state from inserted), (select zip from inserted))
	end
	else begin
		INSERT INTO juvenile (memberID, adult_memberid, birthDate) values ((SELECT @@IDENTITY), @adult_id, (select expirationDate from inserted))
	end
END

go

/*	
 *	VIEWS
 */
 create view view_members
 as
 select M.memberID, M.firstname, M.lastname, M.phone, M.email, A.city, A.street, A.homeNo, A.flatNo, A.zip, A.state, A.expirationDate, NULL as AdultID,  M.active
 from member M
 join adult A on M.memberID = A.memberID
 union
 select M.memberID, M.firstname, M.lastname, M.phone, M.email, A.city, A.street, A.homeNo, A.flatNo, A.zip, A.state, J.birthDate, A.memberID as AdultID, M.active
 from member M
 join juvenile J on J.memberID = M.memberID
 join adult A on J.adult_memberID = A.memberID

go
 
 create view view_films
 as
 SELECT F.filmID, F.title, F.director
	,(SELECT CAST(M.mediumName + ', ' AS VARCHAR(MAX))
		FROM item I
		join medium M on M.mediumID = I.mediumID
		WHERE (I.filmID = F.filmID)
		FOR XML PATH ('')) AS Media
	,(SELECT CAST(C.categoryName + ', ' AS VARCHAR(MAX))
		FROM film_and_category FC
		join category C on C.categoryID = FC.categoryID
		WHERE (FC.filmID = F.filmID)
		FOR XML PATH ('')) AS Kategorie
	,(SELECT CAST(L.labelName + ', ' AS VARCHAR(MAX))
		FROM film_and_label FL
		join label L on L.labelID = FL.labelID
		WHERE (FL.filmID = F.filmID)
		FOR XML PATH ('')) AS Etykiety
	,(select count(*) from copy C where C.filmid =  F.filmID) as Kopie
	,(select COUNT(*) from copy C where C.filmid = F.filmID and C.onLoan = 0) as Dostepnych
FROM film F

go

CREATE VIEW view_topFilms
AS
	SELECT TOP 10 filmID, title, director, SUM(wypozyczen) AS wypozyczen FROM
	(SELECT f.filmID, f.title, COUNT(*) AS wypozyczen FROM film f
	INNER JOIN copy c ON f.filmID=c.filmID
	INNER JOIN loan l ON c.copyID=l.copyID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY f.filmID, f.title
	UNION
	SELECT f.filmID, f.title, COUNT(*) AS wypozyczen FROM film f
	INNER JOIN copy c ON f.filmID=c.filmID
	INNER JOIN loanhist lh ON c.copyID=lh.copyID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY f.filmID, f.title) c
	GROUP BY c.filmID, c.title
	ORDER BY SUM(wypozyczen) DESC

go

CREATE VIEW view_topClients
AS
	SELECT TOP 10 firstname, lastname, SUM(wypozyczen) as wypozyczen from
	(SELECT m.memberID, m.firstname, m.lastname, COUNT(*) AS wypozyczen FROM member m
	INNER JOIN loanhist lh ON m.memberID=lh.memberID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY m.memberID, m.firstname, m.lastname
		--order by COUNT(*) DESC
	UNION
	SELECT m.memberID, m.firstname, m.lastname, COUNT(*) AS wypozyczen FROM member m
	INNER JOIN loan l ON m.memberID=l.memberID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY m.memberID, m.firstname, m.lastname) c
	GROUP BY c.memberID, c.firstname, c.lastname
	ORDER BY SUM(wypozyczen) DESC
