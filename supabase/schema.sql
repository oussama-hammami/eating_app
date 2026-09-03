-- Community recipes schema for Supabase.
-- Run this once before loading supabase/seed/community_recipes.sql.

create table if not exists public."comminutyDishPropositions" (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users (id),
  name text not null,
  calories integer not null,
  protein integer not null,
  carbs integer,
  fat integer,
  portions integer not null default 1,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack', 'drink')),
  photo_path text,
  description text not null default '',
  ingredients jsonb not null default '[]'::jsonb,
  is_community boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public."comminutyDishPropositions" enable row level security;

-- Anyone (incl. anonymous) can read community recipes.
create policy "community recipes are publicly readable"
  on public."comminutyDishPropositions" for select
  using (is_community = true);

-- Signed-in users can read their own private recipes.
create policy "owners can read their own recipes"
  on public."comminutyDishPropositions" for select
  using (auth.uid() = owner_id);

-- Signed-in users can insert/update/delete only their own recipes.
create policy "owners can insert their own recipes"
  on public."comminutyDishPropositions" for insert
  with check (auth.uid() = owner_id);

create policy "owners can update their own recipes"
  on public."comminutyDishPropositions" for update
  using (auth.uid() = owner_id);

create policy "owners can delete their own recipes"
  on public."comminutyDishPropositions" for delete
  using (auth.uid() = owner_id);
