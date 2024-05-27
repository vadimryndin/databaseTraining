use eStore;

drop table if exists Color;

create table Color
(
    ColorID    smallint        not null     auto_increment,
    `Name`     nvarchar(60)    not null,

    constraint PK_Color primary key (ColorID)
);
