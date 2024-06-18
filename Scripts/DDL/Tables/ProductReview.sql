use eStore;

drop table if exists ProductReview;

create table ProductReview
(
    ProductReviewID       smallint        not null     auto_increment,
    ClientID              smallint        not null,
    ProductID             smallint        not null,
    CompanyResponseID     smallint        not null,
    RatingID              smallint        not null,
    Text                  nvarchar(120)   null,
    CreationDateTime      datetime        not null,


    constraint PK_ProductReview primary key (ProductReviewID)
);
