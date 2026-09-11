CREATE TABLE users (
    id UUID PRIMARY KEY,

    email VARCHAR(320) NOT NULL UNIQUE,

    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,

    auth_provider VARCHAR(50),
    provider_subject VARCHAR(255),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);