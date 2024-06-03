use eStore;

drop table if exists Characteristics;

create table Characteristics
(
    ProductID        smallint         not null,
    ColorID          smallint         null,
    SizeID           smallint         null,
	Weight           smallint         null,

    constraint PK_Characteristics primary key (ProductID)
);