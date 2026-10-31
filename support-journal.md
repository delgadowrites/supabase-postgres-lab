## 2026-10-27: EXPLAIN ANALYZE lab

### 1. Slow lookup on a million-row table (missing index)
- **Symptom:** Looking up one user's tasks in a million-row table took about 2 seconds.
- **Cause:** No index on `user_id`. `explain analyze` showed a Seq Scan that read every row and discarded 99.9% of them, a brute force search.
- **Fix:** Created an index on `user_id`.
- **Result:** Bitmap Index Scan, no wasted rows, 12 ms. About 165 times faster.

## 2026-10-31: Supabase React demo build

### 1. ENOENT when starting the dev server
- **Symptom:** `npm run dev` failed with ENOENT: could not read package.json.
- **Cause:** The terminal was in the parent folder, not the project folder.
- **Fix:** `cd` into the folder that contains `package.json`, then run it again.
- **Result:** Server started.

### 2. Invalid path specified in request URL
- **Symptom:** Clicking Send magic link showed an alert: Invalid path specified in request URL.
- **Cause:** The Project URL in `.env.local` ended with `/rest/v1/`. supabase-js adds its own paths, like `/auth/v1/` for sign-in, so the extra path broke the address.
- **Fix:** Trimmed the URL to end at `.supabase.co`, then restarted the server so Vite reloaded `.env.local`.
- **Result:** Magic link sent, sign-in and sign-out worked.

### 3. Blank profile page (PGRST116)
- **Symptom:** Profile page loaded blank: no avatar, username or website. Console showed PGRST116, "Cannot coerce the result to a single JSON object" (406 on the network side).
- **Cause:** The user's row in `profiles` was missing, and `.single()` expects exactly one row.
- **Fix:** Saved the profile again. `upsert` inserted a new row because none existed.
- **Result:** Row restored, and the data persists after refresh.
- **Real-world note:** Users who signed up before the `handle_new_user` trigger existed won't have a profile row. The fix is to backfill their rows.

### 4. Username too short (check constraint, 23514)
- **Symptom:** Clicking Update showed an alert: new row for relation "profiles" violates check constraint "username_length". The Console showed a POST to `/rest/v1/profiles` that returned 400.
- **Cause:** The username had 2 characters. A Postgres check constraint on `profiles` requires 3 or more, so Postgres rejected the row (code 23514) and PostgREST returned it as a 400.
- **Fix:** Saved a username with 3 or more characters.
- **Result:** Update succeeded with no error.
- **Developer tip:** Add the same rule to the form, like `minLength={3}` on the input, so users get a friendly message before the request is ever sent.

### 5. Avatar upload blocked (storage RLS)
- **Symptom:** Uploading an avatar showed an alert: new row violates row-level security policy. The Console showed a POST to `/storage/v1/object/avatars/...` that returned 400.
- **Cause:** The insert policy on `storage.objects` for the `avatars` bucket was missing. Every upload is a row insert, so RLS blocked it.
- **Fix:** Recreated the insert policy for the `avatars` bucket, then re-uploaded an image.
- **Result:** Upload succeeded.
- **Prevention:** When uploads fail with an RLS message, check Storage policies, not table policies. In production, scope uploads to each user's own folder.



