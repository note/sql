use OurRental
insert into film(title, director, description)
values('Pan Tadeusz 2', 'Hoffman', 'Lorem ipsum')

select * from film

create trigger CategoryDelete
on category
for delete
as
begin
	delete from film_and_category where categoryID = (select categoryID from deleted)
end

delete from film where filmID = 10

insert into category(categoryName)
values('History1')

select * from film_and_category

select * from category

insert into film_and_category(categoryID, filmID)
values(1,2)

delete from film_and_category where categoryID = 3

delete from category where categoryID = 1

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

select * from adult
select * from juvenile

exec deleteMember @id=3
exec deleteMember @id=1