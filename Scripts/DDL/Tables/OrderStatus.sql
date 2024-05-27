use eStore;

drop table if exists OrderStatus;

create table OrderStatus
(
    OrderStatusID    smallint        not null     auto_increment,
    `Name`           nvarchar(60)    not null,

    constraint PK_OrderStatus primary key (OrderStatusID)
);
