use eStore;

drop table if exists Size;

create table Size
(
    SizeID     smallint        not null     auto_increment,
    `Name`     nvarchar(60)    not null,

    constraint PK_Size primary key (SizeID)
);
