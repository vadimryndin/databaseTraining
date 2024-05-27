use eStore;

drop table if exists `Order`;

create table `Order`
(
    OrderID                   smallint         not null     auto_increment,
    `Code`                    char(32)         not null,
    CreationDateTime          datetime         not null,
    ShelfLife                 datetime         not null,
    FinalCost                 int              not null,
    StatusID                  tinyint          not null,
    PickUpPointID             tinyint          null,
    WarehouseID               tinyint          null,
    ClientID                  smallint         not null,
    Quantity                  tinyint          not null,
    Cost                      int              not null,

    constraint PK_Order primary key (OrderID)
);