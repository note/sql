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
	declare @on_loan bit
	select @on_loan = onLoan from copy where copyID = @copy_id
	if (@on_loan = 1) begin
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
				update copy set onLoan = 0 where copyID = @copy_id
			end
			else if(@rowcount >= 6) begin
				set @discount=-1
				PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + ' ma juz wypozyczonych 6 filmow'
			end
			else begin
				PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'przetrzymuje filmy'
			end
		end else PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'jest nieaktywny'
	end else PRINT 'Kopia jest juz wypozyczona'
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
		select @time_delay=count(*) from loan where memberID=@member_id and GETDATE() > dueDate
		if (@time_delay > 0) begin
			PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + ' przetrzymuje filmy'
		end
		else begin			
			--tu trzeba napisac szukanie labelek
			insert into reservation (memberID, mediumID, filmID, logDate) Values (@member_id, @medium_id, @film_id, GETDATE())
			
			Declare @label int

			DECLARE labels_cursor CURSOR FOR
			select labelID from film_and_label where filmID=@film_id

			OPEN labels_cursor

			-- Perform the first fetch.
			FETCH NEXT FROM labels_cursor into @label
			-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
			WHILE @@FETCH_STATUS =0
			BEGIN
			INSERT INTO reservation_and_film_and_label (memberID, labelID, filmID, mediumID) VALUES (@memberID, @filmID, @mediumID, @label)
			-- This is executed as long as the previous fetch succeeds.
			FETCH NEXT FROM labels_cursor into @label
			END
			
			CLOSE labels_cursor
			DEALLOCATE labels_cursor 
		end
	end else PRINT 'Uzytkownik o id=' + CAST(@member_id as VARCHAR) + 'jest nieaktywny'
end
go

create procedure insertAdult @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @birthdate date, @street varchar (50), @homeNo varchar (6), @flatNo varchar (6), @city varchar (50), @state varchar (50), @zip char(5)
as begin
	insert into view_members (firstname, lastname, phone, email, birthDate, street, homeNo, flatNo, city, state, zip) values(@firstname, @lastname, @phone, @email, @birthdate, @street, @homeNo, @flatNo, @city, @state, @zip)
end
go

create procedure insertJuvenile @firstname varchar(50), @lastname varchar(50), @phone char(11), @email varchar(100), @birthdate date, @adult_id int
as begin
	insert into view_members (firstname, lastname, phone, email, birthDate, adultID) values(@firstname, @lastname, @phone, @email, @birthdate, @adult_id)
end

go


--procedura usuwajaca zaegle rezerwacje
create procedure refreshReservation
as
begin
	delete from reservation where acceptDate > dateadd(day, 14, getdate())
end

go
