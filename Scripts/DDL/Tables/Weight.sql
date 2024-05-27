use eStore;

drop table if exists Weight;

create table Weight
(
    WeightID     smallint        not null     auto_increment,
    `Name`       nvarchar(60)    not null,

    constraint PK_Weight primary key (WeightID)
);
