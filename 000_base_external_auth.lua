return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "external_auth_table" (
        "id"        UUID                         PRIMARY KEY,
        "created_at"   TIMESTAMP WITHOUT TIME ZONE,
        "token"       TEXT,
        "auth_header"  TEXT,
        "jwt"          TEXT,
        "xlc_headers"  TEXT
      );
    
      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "external_auth_table_token"
                                ON "external_auth_table" ("token");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]],
  },

  cassandra = {
    up = [[
     CREATE TABLE IF NOT EXISTS "external_auth_table" (
        "id"        uuid                         PRIMARY KEY,
        "created_at"   timestamp,
        "token".       text,
        "auth_header"  text,
        "jwt"          text,
        "xlc_headers"  text
      );
    
      CREATE INDEX IF NOT EXISTS ON external_auth_table_token(token);
   ]],
  },    



}