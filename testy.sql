use OurRental
--obsluga usuwania kategorii
insert into film(title, director, description)
values('Pan Tadeusz0', 'Hoffman', 'Lorem ipsum')
insert into film(title, director, description)
values('Pan Tadeusz1', 'Hoffman', 'Lorem ipsum')
insert into film(title, director, description)
values('Pan Tadeusz2', 'Hoffman', 'Lorem ipsum')
insert into film(title, director, description)
values('Pan Tadeusz3', 'Hoffman', 'Lorem ipsum')

select * from film

insert into category(categoryName)
values('History0')
insert into category(categoryName)
values('History1')
insert into category(categoryName)
values('History2')

select * from category

insert into film_and_category(categoryID, filmID)
values(1,1)
insert into film_and_category(categoryID, filmID)
values(1,2)
insert into film_and_category(categoryID, filmID)
values(1,3)
insert into film_and_category(categoryID, filmID)
values(2,2)
insert into film_and_category(categoryID, filmID)
values(2,3)

select * from film_and_category

delete from category where categoryID = 1

--obsluga usuwania kategorii dziala poprawnie!

--obsluga usuwania memberow

insert into member(lastname, firstname,phone, active)
values ('Gajecki', 'Marek', '4846312', 1)

insert into adult(memberID, street, homeNo, city, state, zip, expirationDate)
values(1, 'Mickiewicza', '30', 'Krakow', 'Malopolska', '30500', GETDATE()+(60*60))

insert into member(lastname, firstname, phone, active)
values ('Gajecki', 'Michal', '4846312', 1)
insert into member(lastname, firstname, phone, active)
values ('Gajecki', 'MAciek', '4846312', 1)
insert into member(lastname, firstname, phone, active)
values ('Gajecki', 'adam', '4846312', 1)

insert into juvenile(memberID, birthDate, adult_memberID)
values(2,GETDATE()-(60*60),1)
insert into juvenile(memberID, birthDate, adult_memberID)
values(3,GETDATE()-(60*60),1)
insert into juvenile(memberID, birthDate, adult_memberID)
values(4,GETDATE()-(60*60),1)

select * from member

select * from adult a join member m on a.memberID = m.memberID
select * from juvenile j join member m on j.memberID = m.memberID

exec deleteMember @id=3
exec deleteMember @id=1
--obsluga usuwania memberow dziala poprawnie!