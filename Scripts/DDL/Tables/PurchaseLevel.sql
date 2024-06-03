use eStore;

drop table if exists PurchaseLevel;

create table PurchaseLevel
(
    PurchaseLevelID  smallint        not null     auto_increment,
    `Name`           nvarchar(20)    not null,

    constraint PK_PurchaseLevel primary key (PurchaseLevelID)
);
