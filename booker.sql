-- Current application schema, without catalogue data.
-- Apply only to an empty database; this is not a migration script.
-- Keep this file and the DBIx::Class mappings in sync with schema changes.

BEGIN TRANSACTION;

CREATE TABLE person (
    id integer primary key autoincrement,
    name text not null,
    sort_name text not null,
    slug varchar(120),
    biography text
);

CREATE TABLE event (
    id integer primary key autoincrement,
    year text,
    slug varchar(50)
);

CREATE TABLE book (
    id integer primary key autoincrement,
    title text not null,
    author_id int not null,
    sort_title text not null,
    asin text not null,
    slug varchar(120),
    event_id int not null default 1 references event(id),
    is_winner boolean not null default false,
    blurb text,
    isbn13 TEXT,
    isbn_source TEXT,
    foreign key (author_id) references person(id)
);

CREATE TABLE judge (
    event_id int not null,
    person_id int not null,
    is_chair boolean,
    primary key (event_id, person_id),
    foreign key (event_id) references event(id),
    foreign key (person_id) references person(id)
);

CREATE INDEX book_author_idx ON book(author_id);

CREATE VIEW author AS
SELECT
    p.id,
    p.name,
    p.sort_name,
    p.slug,
    p.biography,
    COUNT(b.id) AS books_count
FROM person p
JOIN book b ON b.author_id = p.id
GROUP BY p.id, p.name, p.sort_name, p.slug, p.biography;

COMMIT;
