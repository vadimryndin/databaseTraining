use eStore;

drop table if exists Warehouse;

create table Warehouse
(
    WarehouseID      smallint        not null     auto_increment,
    `Name`           nvarchar(60)    not null,
    Address          nvarchar(255)   not null,
    OpeningHours     nvarchar(255)   not null,

    constraint PK_Warehouse primary key (WarehouseID)
);
