use eStore;

drop table if exists OrderProduct;

create table OrderProduct
(
    OrderID                   smallint         not null,
    ProductID                 smallint         not null,
    ProductPrice              int              null,
    ProductQuantity           smallint         null,
    DiscountValue             smallint         null,

    constraint PK_OrderProduct primary key (OrderID, ProductID)
);