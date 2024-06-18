use eStore;

drop table if exists OrderReview;

create table OrderReview
(
    OrderReviewID       smallint        not null     auto_increment,
    ClientID            smallint        not null,
    OrderID             smallint        not null,
    CompanyResponseID   smallint        not null,
    RatingID            smallint        not null,
    Text                nvarchar(120)   null,

    constraint PK_OrderReview primary key (OrderReviewID)
);
