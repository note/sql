use OurRental

select * from film
select * from category
select * from film_and_category
delete from category where categoryID = 8

--powinno nie zadzialac - za kroki numer telefonu:
insert into member(lastname, firstname,phone, active) values ('Gajecki', 'Marek', '486575122', 1)

--Zakomentowalem, bo jak mowila dr Zygmunt, usuwanie memberow to zly pomysl
--exec deleteMember @id=5
--exec deleteMember @id=1
--obsluga usuwania memberow dziala poprawnie!

select * from member
select * from adult
select * from juvenile


insert into juvenile (memberID, adult_memberID, birthDate) values (3, 7, GETDATE()+100) -- powinno nie zadzialac - birthdate>getdate()
insert into juvenile (memberID, adult_memberID, birthDate) values (3, 7, '12-11-1877') -- powinno nie zadzialac

insert into member (lastname, firstname, phone, active) values ('Dylan', 'Bob', '1254354354353', 1) -- powinno nie zadzialac - telefon nie ma 11 znakow

select * from medium
select * from item
select * from loan
select * from loanhist
select * from copy

--widoki testing
select * from view_members
select * from view_films


select * from category
select * from label
select * from loan
select * from copy
