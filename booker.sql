CREATE TABLE person (id integer primary key autoincrement, name text not null, sort_name text not null);
CREATE TABLE event (id integer primary key autoincrement, year text);
CREATE TABLE book (id integer primary key autoincrement, title text not null, author_id int not null, sort_title text not null, foreign key (author_id) references person(id));
CREATE TABLE entry (book_id int not null, event_id int not null, is_winner boolean, primary key(book_id, event_id), foreign key(book_id) references book(id), foreign key(event_id) references event(id));
CREATE TABLE judge (event_id int not null, person_id not null, is_chair boolean, primary key(event_id, person_id), foreign key (event_id) references event(id), foreign key (person_id) references person(id));
