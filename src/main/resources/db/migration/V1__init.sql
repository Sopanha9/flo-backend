-- ============================================================
-- Flo App — Initial Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────
CREATE TABLE users (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT        NOT NULL,
    avatar_url    TEXT,
    bio           TEXT,
    role          VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- PROFILES (extended user info)
-- ─────────────────────────────────────────────
CREATE TABLE profiles (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name  VARCHAR(100),
    location      VARCHAR(100),
    website       TEXT,
    followers_count INT       NOT NULL DEFAULT 0,
    following_count INT       NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_profiles_user UNIQUE (user_id)
);

-- ─────────────────────────────────────────────
-- MOODS
-- ─────────────────────────────────────────────
CREATE TABLE moods (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score       SMALLINT    NOT NULL CHECK (score BETWEEN 1 AND 10),
    label       VARCHAR(50),
    note        TEXT,
    logged_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_moods_user_logged ON moods(user_id, logged_at DESC);

-- ─────────────────────────────────────────────
-- HABITS
-- ─────────────────────────────────────────────
CREATE TABLE habits (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title         VARCHAR(100) NOT NULL,
    description   TEXT,
    frequency     VARCHAR(20) NOT NULL DEFAULT 'DAILY', -- DAILY, WEEKLY, CUSTOM
    target_count  INT         NOT NULL DEFAULT 1,
    color         VARCHAR(7),  -- hex color
    icon          VARCHAR(50),
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- HABIT LOGS
-- ─────────────────────────────────────────────
CREATE TABLE habit_logs (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id    UUID        NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    logged_date DATE        NOT NULL,
    count       INT         NOT NULL DEFAULT 1,
    note        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_habit_log_date UNIQUE (habit_id, logged_date)
);

CREATE INDEX idx_habit_logs_habit_date ON habit_logs(habit_id, logged_date DESC);

-- ─────────────────────────────────────────────
-- JOURNAL ENTRIES
-- ─────────────────────────────────────────────
CREATE TABLE journal_entries (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(200),
    content     TEXT        NOT NULL,
    mood_score  SMALLINT    CHECK (mood_score BETWEEN 1 AND 10),
    is_private  BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_journal_user_created ON journal_entries(user_id, created_at DESC);

-- ─────────────────────────────────────────────
-- TAGS
-- ─────────────────────────────────────────────
CREATE TABLE tags (
    id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name    VARCHAR(50) NOT NULL,
    CONSTRAINT uq_tag_user_name UNIQUE (user_id, name)
);

CREATE TABLE journal_tags (
    journal_id  UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    tag_id      UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (journal_id, tag_id)
);

-- ─────────────────────────────────────────────
-- GOALS
-- ─────────────────────────────────────────────
CREATE TABLE goals (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    category      VARCHAR(50),
    target_date   DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, ABANDONED
    progress      SMALLINT    NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- GOAL MILESTONES
-- ─────────────────────────────────────────────
CREATE TABLE goal_milestones (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id     UUID        NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    is_done     BOOLEAN     NOT NULL DEFAULT FALSE,
    due_date    DATE,
    completed_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- FOLLOWS (social graph)
-- ─────────────────────────────────────────────
CREATE TABLE follows (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id <> following_id)
);

-- ─────────────────────────────────────────────
-- NOTIFICATIONS
-- ─────────────────────────────────────────────
CREATE TABLE notifications (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(50) NOT NULL,
    title       VARCHAR(200) NOT NULL,
    body        TEXT,
    is_read     BOOLEAN     NOT NULL DEFAULT FALSE,
    reference_id UUID,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);

-- ─────────────────────────────────────────────
-- updated_at trigger function
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated         BEFORE UPDATE ON users          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_profiles_updated      BEFORE UPDATE ON profiles       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_habits_updated        BEFORE UPDATE ON habits         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_journal_updated       BEFORE UPDATE ON journal_entries FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_goals_updated         BEFORE UPDATE ON goals          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
