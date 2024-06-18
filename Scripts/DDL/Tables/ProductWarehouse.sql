use eStore;

drop table if exists ProductWarehouse;

create table ProductWarehouse
(
    ProductID                  smallint         not null,
    WarehouseID                smallint         not null,
    ProductQuantity            int              not null,

    constraint PK_ProductWarehouse primary key (WarehouseID, ProductID)
);