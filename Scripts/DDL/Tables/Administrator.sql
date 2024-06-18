use eStore;

drop table if exists Administrator;

create table Administrator
(
    AdministratorID     tinyint        not null     auto_increment,
    Login               varchar(20)    not null,
    PasswordHash        char(32)       not null,

    constraint PK_Administrator primary key (AdministratorID)
);


