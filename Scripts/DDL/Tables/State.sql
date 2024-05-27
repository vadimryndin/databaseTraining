use eStore;

drop table if exists State;

create table State
(
    StateID    smallint        not null     auto_increment,
    `Name`     nvarchar(60)    not null,

    constraint PK_State primary key (StateID)
);
