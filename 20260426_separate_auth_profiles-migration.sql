-- Migration: Separate institution and admin accounts from person profile creation.
-- This migration updates the auth.users trigger function so it inserts rows into public.people_with_disability
-- only when the new auth user contains real person-profile metadata.

-- Step 1: Backup any institution or admin rows that were inserted by mistake into people_with_disability.
create table if not exists public.people_with_disability_role_cleanup_backup as
select p.*
from public.people_with_disability p
where false;

-- Step 2: Copy the currently misclassified institution and admin rows into the backup table before cleanup.
insert into public.people_with_disability_role_cleanup_backup
select p.*
from public.people_with_disability p
where exists (
  select 1
  from public.institutions i
  where i.id = p.id
)
or exists (
  select 1
  from public.admin a
  where a.id = p.id
);

-- Step 3: Remove institution and admin rows that were inserted by mistake into people_with_disability.
delete from public.people_with_disability p
where exists (
  select 1
  from public.institutions i
  where i.id = p.id
)
or exists (
  select 1
  from public.admin a
  where a.id = p.id
);

-- Step 4: Replace the auth.users trigger function so only real person accounts are inserted into people_with_disability.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  -- This guard skips institutions and admins because they do not send the person-profile metadata fields.
  if coalesce(new.raw_user_meta_data->>'full_name', '') = ''
     and coalesce(new.raw_user_meta_data->>'disability_type', '') = ''
     and coalesce(new.raw_user_meta_data->>'age', '') = ''
     and coalesce(new.raw_user_meta_data->>'gender', '') = ''
     and coalesce(new.raw_user_meta_data->>'responsible_person', '') = '' then
    return new;
  end if;

  -- This insert keeps creating people_with_disability rows only for real person accounts.
  insert into public.people_with_disability (
    id,
    created_at,
    full_name,
    phone,
    email,
    disability_type,
    password,
    responsible_person,
    gender,
    age
  )
  values (
    new.id,
    now(),
    nullif(new.raw_user_meta_data->>'full_name', ''),
    nullif(new.raw_user_meta_data->>'phone', ''),
    new.email,
    nullif(new.raw_user_meta_data->>'disability_type', ''),
    null,
    nullif(new.raw_user_meta_data->>'responsible_person', ''),
    nullif(new.raw_user_meta_data->>'gender', ''),
    nullif(new.raw_user_meta_data->>'age', '')::bigint
  );

  return new;
end;
$function$;

-- Step 5: Ensure the trigger still points to the updated function without recreating the trigger itself.
-- No trigger recreation is needed because on_auth_user_created already calls public.handle_new_user().
