use eStore;

drop table if exists SystemRole;

create table SystemRole
(
    SystemRoleID    tinyint         not null     auto_increment,
    `Name`          nvarchar(30)    not null,

    constraint PK_SystemRole primary key (SystemRoleID)
);


