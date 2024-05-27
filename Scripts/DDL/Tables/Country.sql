use eStore;

drop table if exists Country;

create table Country
(
    CountryID    smallint        not null     auto_increment,
    `Name`       nvarchar(60)    not null,

    constraint PK_Country primary key (CountryID)
);
