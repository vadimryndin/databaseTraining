use eStore;

drop table if exists ProductPickUpPoint;

create table ProductPickUpPoint
(
    ProductID                  smallint         not null,
    PickUpPointID              smallint         not null,
    ProductQuantity            int              not null,

    constraint PK_ProductPickUpPoint primary key (PickUpPointID, ProductID)
);