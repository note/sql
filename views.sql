/*	
 *	VIEWS
 */
 create view view_members
 as
 select M.memberID, M.firstname, M.lastname, M.phone, M.email, A.city, A.street, A.homeNo, A.flatNo, A.zip, A.state, M.birthDate, NULL as AdultID,  M.active
 from member M
 join adult A on M.memberID = A.memberID
 union
 select M.memberID, M.firstname, M.lastname, M.phone, M.email, A.city, A.street, A.homeNo, A.flatNo, A.zip, A.state, M.birthDate, A.memberID as AdultID, M.active
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
	, F.description
FROM film F

go

CREATE VIEW view_topFilms
AS
	SELECT TOP 10 filmID, title, director, SUM(wypozyczen) AS wypozyczen FROM
	(SELECT f.filmID, f.title, f.director, COUNT(*) AS wypozyczen FROM film f
	INNER JOIN copy c ON f.filmID=c.filmID
	INNER JOIN loan l ON c.copyID=l.copyID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY f.filmID, f.title, f.director
	UNION
	SELECT f.filmID, f.title, f.director, COUNT(*) AS wypozyczen FROM film f
	INNER JOIN copy c ON f.filmID=c.filmID
	INNER JOIN loanhist lh ON c.copyID=lh.copyID
	WHERE DATEDIFF(dd, outDate, GETDATE())<=30
	GROUP BY f.filmID, f.title, f.director) c
	GROUP BY c.filmID, c.title, c.director
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
go

CREATE VIEW view_reservations
AS
	select m.memberID, m.firstname, m.lastname, m.phone, f.title, f.director, medium.mediumName, r.logDate, r.acceptDate, f.filmPrice*medium.priceMultiply Cena
	from reservation r
	join member m on m.memberID = r.memberID
	join film f on f.filmID = r.filmID
	join medium on medium.mediumID = r.mediumID
go