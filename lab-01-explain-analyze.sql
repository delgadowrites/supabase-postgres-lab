-- Lab 01: EXPLAIN ANALYZE, seq scan vs index on user_id

-- 1. Create the table
create table tasks_big (
  id bigint generated always as identity primary key,
  user_id int,
  title text,
  done boolean,
  created_at timestamptz
);

-- 2. Fill it with 1,000,000 fake rows
insert into tasks_big (user_id, title, done, created_at)
select (random() * 1000)::int,
       'task ' || n,
       random() < 0.5,
       now() - (n || ' minutes')::interval
from generate_series(1, 1000000) as n;

-- 3. Check the row counts
select count(*) from tasks_big;                     -- result: 1,000,000
select count(*) from tasks_big where user_id = 42;  -- result: 949

-- 4. Query plan without an index
explain analyze select * from tasks_big where user_id = 42;
-- result: Parallel Seq Scan, ~999,000 rows removed by filter, 2,012 ms

-- 5. Add the index
create index on tasks_big (user_id);

-- 6. Query plan with the index
explain analyze select * from tasks_big where user_id = 42;
-- result: Bitmap Index Scan + Bitmap Heap Scan, no rows removed, 12 ms
