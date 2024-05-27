use eStore;

drop table if exists CatalogSection;

create table CatalogSection
(
    CatalogSectionID    smallint        not null     auto_increment,
    `Name`              nvarchar(60)    not null,
    ParentSectionID     smallint        null,

    constraint PK_CatalogSection primary key (CatalogSectionID)
);
