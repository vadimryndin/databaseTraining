use eStore;

drop table if exists Employee;

create table Employee
(
    EmployeeID                smallint         not null     auto_increment,
    FullName                  nvarchar(120)    not null,
    Login                     nvarchar(60)     not null,
    PasswordHash              char(32)         not null,
    PhoneNumber               varchar(20)      null,
    JobPositionID             smallint         null,
    ContractExpirationDate    date             null,
    SystemRoleID              tinyint          not null,
    CreatorAdministratorID    tinyint          not null,

    constraint PK_Employee primary key (EmployeeID)
);


