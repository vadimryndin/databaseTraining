use eStore;

drop table if exists AuthorizationEmployeeLog;

create table AuthorizationEmployeeLog
(
    EmployeeID               smallint    not null,
    AuthorizationDateTime    datetime    not null,

    constraint PK_AuthorizationEmployeeLog primary key (EmployeeID, AuthorizationDateTime)
);


