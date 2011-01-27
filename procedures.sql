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

--Returns discount in percentage. If loan can't be insterted then returns -1.
--Also will not allow to make a loan for one who is keeping films too long
create procedure insertLoan @copy_id int, @member_id int, @discount int OUTPUT
as
begin
	declare @active int
	select @active=active from member where memberID = @member_id
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

--will not allow to make a reservation for one who is keeping films too long
create procedure insertReservation @member_id int, @film_id int, @medium_id int
as
begin
	declare @active int
	select @active=active from member where memberID = @member_id
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

create procedure insertAdult @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @birthdate date, @street varchar (50), @homeNo varchar (6), @flatNo varchar (6), @city varchar (50), @state varchar (50), @zip char(5)
as begin
	insert into view_members (firstname, lastname, phone, email, birthDate, street, homeNo, flatNo, city, state, zip) values(@firstname, @lastname, @phone, @email, @birthdate, @street, @homeNo, @flatNo, @city, @state, @zip)
end
go

create procedure insertJuvenile @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @birthdate date, @adult_id int
as begin
	insert into view_members (firstname, lastname, phone, email, birthDate, adult_memberID) values(@firstname, @lastname, @phone, @email, @birthdate, @adult_id)
end
go
