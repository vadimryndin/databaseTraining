use eStore;

drop table if exists CompanyResponse;

create table CompanyResponse
(
    CompanyResponseID    smallint        not null     auto_increment,
    `Name`               nvarchar(60)    not null,

    constraint PK_CompanyResponse primary key (CompanyResponseID)
);
