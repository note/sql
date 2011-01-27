/*	
 *	TRIGGERS
 */

CREATE TRIGGER tr_deleteLoan
ON loan
AFTER DELETE
AS BEGIN
	declare @to_pay decimal
	if(getdate() > (select dueDate from deleted)) begin
		declare @days int
		select @days = datediff(day, getdate(), dueDate) from deleted
		set @to_pay = 0.5 * @days
	end
	INSERT INTO loanhist (outDate, copyID, memberID, dueDate, fineAssessed) VALUES ((SELECT outDate from deleted), (SELECT copyID from deleted), (SELECT memberID from deleted), (SELECT dueDate from deleted), @to_pay) --todo naliczanie kary
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

create TRIGGER tr_insertViewMembers
on view_members
INSTEAD OF INSERT
AS BEGIN
	INSERT INTO member (lastname, firstname, birthDate, phone, email) values ((select lastname from inserted), (select firstname from inserted), (select birthDate from inserted), (select phone from inserted), (select email from inserted))
	declare @adult_id int
	SET @adult_id = (SELECT adultid from inserted)
	IF (@adult_id is null) and (dateadd(year, 18, (select birthDate from inserted)) <= getdate()) begin
		INSERT INTO adult (memberID, street, homeNo, flatNo, city, state, zip) VALUES ((SELECT @@IDENTITY), (select street from inserted), (select homeNo from inserted), (select flatNo from inserted), (select city from inserted), (select state from inserted), (select zip from inserted))
	end
	else if dateadd(year, 18, (select birthDate from inserted)) > getdate() begin
		INSERT INTO juvenile (memberID, adult_memberid) values ((SELECT @@IDENTITY), @adult_id)
	end else begin 
		PRINT 'Probujesz dodac osobe dorosla do juvenile'
	end
END

go
