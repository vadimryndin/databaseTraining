use eStore;

drop table if exists JobPosition;

create table JobPosition
(
    JobPositionID    smallint        not null     auto_increment,
    `Name`           nvarchar(60)    not null,

    constraint PK_JobPosition primary key (JobPositionID)
);


