use eStore;

drop table if exists `Order`;

create table `Order`
(
    OrderID                   smallint         not null     auto_increment,
    `Code`                    char(32)         not null,
    CreationDateTime          datetime         not null,
    ShelfLife                 datetime         not null,
    FinalCost                 int              not null,
    StatusID                  smallint         not null,
    PickUpPointID             smallint         null,
    WarehouseID               smallint         null,
    ClientID                  smallint         not null,
    Quantity                  tinyint          not null,
    Cost                      int              not null,

    constraint PK_Order primary key (OrderID)
);