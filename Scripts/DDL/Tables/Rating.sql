use eStore;

drop table if exists Rating;

create table Rating
(
    RatingID       smallint        not null     auto_increment,
    `Name`         smallint        not null,

    constraint PK_Rating primary key (RatingID)
);
