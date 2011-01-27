use OurRental

select * from film
select * from category
select * from film_and_category
delete from category where categoryID = 8

--powinno nie zadzialac - za krotki numer telefonu:
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

SELECT @@IDENTITY from member
select
--widoki testing
select * from view_members
insert into view_members (firstname, lastname, phone, adultid) values('lou', 'reed', '12345678901')
select * from view_films
exec insertAdult 'patry333k', 'fadf', '21345678901', 'jakis@mail.pl', 'czarnowiejska', '12', '54', 'krakow', 'malopolska', '33233'
exec insertJuvenile 'Asafa', 'fadf', '21345678901', 'jakis@mail.pl', '11/10/99', 814
select top 5 * from member order by memberID desc
select top 5 * from juvenile order by memberID desc
select * from view_topFilms
select * from view_topClients

--setMemberActive
exec setMemberActive 25, 0 -- ma dzieci o memberID 1284 1285
select * from member where memberID=1284 --sprawdzamy czy active == 0

select * from category
select * from label
select * from loan
select * from copy