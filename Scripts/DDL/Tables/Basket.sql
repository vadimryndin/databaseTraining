use eStore;

drop table if exists Basket;

create table Basket
(
    ClientID                   smallint         not null,
    ProductID                  smallint         not null,
    ProductQuantity            int              not null,

    constraint PK_Basket primary key (ClientID, ProductID)
);