use eStore;

drop table if exists PickUpPoint;

create table PickUpPoint
(
    PickUpPointID    smallint        not null     auto_increment,
    `Name`           nvarchar(60)    not null,
    Address          nvarchar(255)   not null,
    WorkingTime      nvarchar(255)   not null,

    constraint PK_PickUpPoint primary key (PickUpPointID)
);
