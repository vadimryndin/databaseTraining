use eStore;

drop table if exists Brand;

create table Brand
(
    BrandID    smallint        not null     auto_increment,
    `Name`     nvarchar(60)    not null,

    constraint PK_Brand primary key (BrandID)
);
