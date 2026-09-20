-- Booker Prize 2026 shortlist preparation
--
-- Prepared 2026-09-20 for the CURRENT readabooker schema.
--
-- TUESDAY WORKFLOW
-- ----------------
-- 1. When the shortlist is announced, delete the seven BOOK blocks below
--    for books that did not make the shortlist.
-- 2. Back up booker.db.
-- 3. Run:
--        sqlite3 booker.db < Booker-2026.sql
-- 4. Run the normal site build and inspect the 2026 page.
--
-- The file is transactional. It uses lookups rather than hard-coded IDs and
-- reuses people already present in the database.
--
-- ISBN-13 values are UK print editions, used by Book->image() to request
-- cover images from covers.openlibrary.org.
--
-- ASIN values supplied manually from Amazon on 2026-09-20.

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- Event
-- ---------------------------------------------------------------------------

INSERT INTO event (year, slug)
SELECT '2026', '2026'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE year = '2026');

UPDATE event
SET slug = COALESCE(slug, '2026')
WHERE year = '2026';

-- ---------------------------------------------------------------------------
-- Judges
-- ---------------------------------------------------------------------------
INSERT INTO person (name, sort_name)
SELECT 'Mary Beard', 'Beard, Mary'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Mary Beard');

INSERT OR IGNORE INTO judge (event_id, person_id, is_chair)
SELECT e.id, p.id, 1
FROM event e CROSS JOIN person p
WHERE e.year = '2026' AND p.name = 'Mary Beard';

INSERT INTO person (name, sort_name)
SELECT 'Raymond Antrobus', 'Antrobus, Raymond'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Raymond Antrobus');

INSERT OR IGNORE INTO judge (event_id, person_id, is_chair)
SELECT e.id, p.id, 0
FROM event e CROSS JOIN person p
WHERE e.year = '2026' AND p.name = 'Raymond Antrobus';

INSERT INTO person (name, sort_name)
SELECT 'Jarvis Cocker', 'Cocker, Jarvis'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Jarvis Cocker');

INSERT OR IGNORE INTO judge (event_id, person_id, is_chair)
SELECT e.id, p.id, 0
FROM event e CROSS JOIN person p
WHERE e.year = '2026' AND p.name = 'Jarvis Cocker';

INSERT INTO person (name, sort_name)
SELECT 'Rebecca Liu', 'Liu, Rebecca'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Rebecca Liu');

INSERT OR IGNORE INTO judge (event_id, person_id, is_chair)
SELECT e.id, p.id, 0
FROM event e CROSS JOIN person p
WHERE e.year = '2026' AND p.name = 'Rebecca Liu';

INSERT INTO person (name, sort_name)
SELECT 'Patricia Lockwood', 'Lockwood, Patricia'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Patricia Lockwood');

INSERT OR IGNORE INTO judge (event_id, person_id, is_chair)
SELECT e.id, p.id, 0
FROM event e CROSS JOIN person p
WHERE e.year = '2026' AND p.name = 'Patricia Lockwood';

-- ===========================================================================
-- BOOK: The Shadow of the Object — Chloe Aridjis
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Chloe Aridjis', 'Aridjis, Chloe'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Chloe Aridjis');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Shadow of the Object',
  p.id,
  'Shadow of the Object',
  'B0FHVCRB24',
  'the-shadow-of-the-object',
  e.id,
  0,
  '9781784746384',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Chloe Aridjis'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Shadow of the Object'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: Switzy — Emma Cline
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Emma Cline', 'Cline, Emma'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Emma Cline');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'Switzy',
  p.id,
  'Switzy',
  'B0G68XLF7J',
  'switzy',
  e.id,
  0,
  '9781784746643',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Emma Cline'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'Switzy'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: Helen of Nowhere — Makenna Goodman
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Makenna Goodman', 'Goodman, Makenna'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Makenna Goodman');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'Helen of Nowhere',
  p.id,
  'Helen of Nowhere',
  '1804272205',
  'helen-of-nowhere',
  e.id,
  0,
  '9781804272206',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Makenna Goodman'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'Helen of Nowhere'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The End of Everything — M. John Harrison
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'M. John Harrison', 'Harrison, M. John'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'M. John Harrison');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The End of Everything',
  p.id,
  'End of Everything',
  '1800812949',
  'the-end-of-everything',
  e.id,
  0,
  '9781800812949',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'M. John Harrison'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The End of Everything'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The Disappearers — Marlon James
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Marlon James', 'James, Marlon'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Marlon James');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Disappearers',
  p.id,
  'Disappearers',
  '0241714400',
  'the-disappearers',
  e.id,
  0,
  '9780241714409',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Marlon James'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Disappearers'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: Black Bag — Luke Kennard
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Luke Kennard', 'Kennard, Luke'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Luke Kennard');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'Black Bag',
  p.id,
  'Black Bag',
  '1399826115',
  'black-bag',
  e.id,
  0,
  '9781399826112',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Luke Kennard'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'Black Bag'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The Renovation — Kenan Orhan
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Kenan Orhan', 'Orhan, Kenan'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Kenan Orhan');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Renovation',
  p.id,
  'Renovation',
  'B0FK46PVD3',
  'the-renovation',
  e.id,
  0,
  '9780241745779',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Kenan Orhan'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Renovation'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: May We Feed the King — Rebecca Perry
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Rebecca Perry', 'Perry, Rebecca'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Rebecca Perry');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'May We Feed the King',
  p.id,
  'May We Feed the King',
  'B0FT5SY4F7',
  'may-we-feed-the-king',
  e.id,
  0,
  '9781803513867',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Rebecca Perry'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'May We Feed the King'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The Palm House — Gwendoline Riley
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Gwendoline Riley', 'Riley, Gwendoline'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Gwendoline Riley');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Palm House',
  p.id,
  'Palm House',
  'B0FLWX87D6',
  'the-palm-house',
  e.id,
  0,
  '9781035021048',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Gwendoline Riley'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Palm House'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The Things We Never Say — Elizabeth Strout
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Elizabeth Strout', 'Strout, Elizabeth'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Elizabeth Strout');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Things We Never Say',
  p.id,
  'Things We Never Say',
  '0241814308',
  'the-things-we-never-say',
  e.id,
  0,
  '9780241814307',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Elizabeth Strout'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Things We Never Say'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: John of John — Douglas Stuart
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Douglas Stuart', 'Stuart, Douglas'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Douglas Stuart');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'John of John',
  p.id,
  'John of John',
  'B0DSK26L98',
  'john-of-john',
  e.id,
  0,
  '9781035086955',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Douglas Stuart'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'John of John'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: All Them Dogs — Djamel White
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Djamel White', 'White, Djamel'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Djamel White');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'All Them Dogs',
  p.id,
  'All Them Dogs',
  'B0DW5BWV12',
  'all-them-dogs',
  e.id,
  0,
  '9781399824460',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Djamel White'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'All Them Dogs'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

-- ===========================================================================
-- BOOK: The Vivisectors — Missouri Williams
-- Delete this entire block on Tuesday if the book is not shortlisted.
-- ===========================================================================

INSERT INTO person (name, sort_name)
SELECT 'Missouri Williams', 'Williams, Missouri'
WHERE NOT EXISTS (SELECT 1 FROM person WHERE name = 'Missouri Williams');

INSERT INTO book
  (title, author_id, sort_title, asin, slug, event_id, is_winner,
   isbn13, isbn_source)
SELECT
  'The Vivisectors',
  p.id,
  'Vivisectors',
  'B0FT1WLTWJ',
  'the-vivisectors',
  e.id,
  0,
  '9780008725280',
  'manual'
FROM person p CROSS JOIN event e
WHERE p.name = 'Missouri Williams'
  AND e.year = '2026'
  AND NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.title = 'The Vivisectors'
      AND b.author_id = p.id
      AND b.event_id = e.id
  );

COMMIT;
