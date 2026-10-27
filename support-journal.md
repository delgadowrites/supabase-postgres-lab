Symptom: Looking up one user’s tasks in a million-row table took about 2 seconds.
Cause: No index on user_id. explain analyze showed a Seq Scan that read every row and discarded 99.9% of them, a brute force search.
Fix: Created an index on user_id.
Result: Bitmap Index Scan, no wasted rows, 12 ms. About 165 times faster.
