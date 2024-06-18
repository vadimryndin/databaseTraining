use eStore;

drop table if exists Product;

create table Product
(
    ProductID                 smallint         not null     auto_increment,
    `Code`                    char(32)         not null,
    BrandID                   smallint         not null,
    `Name`                    nvarchar(60)     not null,
    Price                     int              not null,
    StateID                   smallint         not null,
    CatalogSectionID          smallint         null,
    ColorID                   smallint         null,
    SizeID                    smallint         null,
    Weight                    nvarchar(20)     null,

    constraint PK_Product primary key (ProductID)
);