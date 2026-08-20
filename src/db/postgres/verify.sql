DO $$
DECLARE
    actual_tables integer;
    actual_columns integer;
    actual_primary_keys integer;
    actual_foreign_keys integer;
BEGIN
    SELECT count(*) INTO actual_tables
    FROM information_schema.tables
    WHERE table_schema = 'heroes_watch' AND table_type = 'BASE TABLE';

    SELECT count(*) INTO actual_columns
    FROM information_schema.columns
    WHERE table_schema = 'heroes_watch';

    SELECT count(*) INTO actual_primary_keys
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
    WHERE n.nspname = 'heroes_watch' AND c.contype = 'p';

    SELECT count(*) INTO actual_foreign_keys
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
    WHERE n.nspname = 'heroes_watch' AND c.contype = 'f';

    IF actual_tables <> 173 THEN
        RAISE EXCEPTION 'Expected 173 tables, found %', actual_tables;
    END IF;
    IF actual_columns <> 1285 THEN
        RAISE EXCEPTION 'Expected 1285 columns, found %', actual_columns;
    END IF;
    IF actual_primary_keys <> 173 THEN
        RAISE EXCEPTION 'Expected 173 primary keys, found %', actual_primary_keys;
    END IF;
    IF actual_foreign_keys <> 349 THEN
        RAISE EXCEPTION 'Expected 349 foreign keys, found %', actual_foreign_keys;
    END IF;
END
$$;

SELECT
    'b04dd68ee09f7a1f86c055a2e3d01c690daf2791343ad7ca33bc637c59a58673' AS source_sha256,
    173 AS tables,
    1285 AS columns,
    349 AS foreign_keys;
