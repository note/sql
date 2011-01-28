use master
create login Kasjer with password = 'Kasjer'

GO

create login Administrator with password = 'administrator'

GO

create login Klient with password = 'klient'

GO

create login Wlasciciel with password = 'Wlasciciel'

GO

use OurRental

create user Kasjer for login Kasjer with DEFAULT_SCHEMA=[dbo]

GO

create user Administrator for login Administrator with DEFAULT_SCHEMA=[dbo]

GO

create user Klient for login Klient with DEFAULT_SCHEMA=[dbo]

GO

create user Wlasciciel for login Wlasciciel with DEFAULT_SCHEMA=[dbo]

GO

use OurRental
grant select, control, execute, insert, delete, update, references, view definition, take ownership on schema ::[dbo] to Administrator
GO

grant select, execute on schema ::[dbo] to Kasjer
GO

grant select, execute on schema ::[dbo] to Wlasciciel
GO

grant select on view_films to Klient