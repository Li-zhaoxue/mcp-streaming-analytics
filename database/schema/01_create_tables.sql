-- Streaming Analytics Database Schema
-- Designed for advanced analytics: engagement, churn, funnel metrics, cohort analysis

-- Users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    country VARCHAR(2),
    subscription_tier VARCHAR(20) CHECK (subscription_tier IN ('free', 'premium', 'family', 'student')),
    subscription_start_date DATE,
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    account_status VARCHAR(20) CHECK (account_status IN ('active', 'churned', 'dormant', 'trial')) DEFAULT 'active',
    churn_date TIMESTAMP,
    churn_reason VARCHAR(100),
    lifetime_value DECIMAL(10,2) DEFAULT 0,
    acquisition_channel VARCHAR(50),
    referral_code VARCHAR(50)
);

-- Content table (movies, shows, songs, albums)
CREATE TABLE content (
    content_id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content_type VARCHAR(20) CHECK (content_type IN ('movie', 'series', 'song', 'album', 'podcast')),
    genre VARCHAR(100),
    sub_genre VARCHAR(100),
    release_date DATE,
    duration_seconds INTEGER,
    artist_creator VARCHAR(255),
    description TEXT,
    rating DECIMAL(3,2),
    language VARCHAR(50),
    is_original BOOLEAN DEFAULT false,
    production_cost DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Streaming events (plays, watches) - Core engagement data
CREATE TABLE streaming_events (
    event_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    content_id INTEGER REFERENCES content(content_id),
    session_id UUID NOT NULL,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    duration_seconds INTEGER,
    completion_percentage DECIMAL(5,2),
    device_type VARCHAR(50) CHECK (device_type IN ('mobile', 'desktop', 'tablet', 'tv', 'smart_speaker')),
    platform VARCHAR(50) CHECK (platform IN ('ios', 'android', 'web', 'roku', 'appletv', 'chromecast', 'firetv')),
    quality VARCHAR(20) CHECK (quality IN ('low', 'medium', 'high', 'hd', '4k')),
    location_country VARCHAR(2),
    location_city VARCHAR(100),
    buffering_count INTEGER DEFAULT 0,
    buffering_duration_seconds INTEGER DEFAULT 0,
    is_binge_watch BOOLEAN DEFAULT false,
    autoplay BOOLEAN DEFAULT false
);

-- User sessions - for engagement tracking
CREATE TABLE user_sessions (
    session_id UUID PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    session_duration_seconds INTEGER,
    device_type VARCHAR(50),
    platform VARCHAR(50),
    pages_viewed INTEGER DEFAULT 0,
    content_items_played INTEGER DEFAULT 0,
    searches_performed INTEGER DEFAULT 0
);

-- User interactions (likes, saves, shares)
CREATE TABLE user_interactions (
    interaction_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    content_id INTEGER REFERENCES content(content_id),
    interaction_type VARCHAR(20) CHECK (interaction_type IN ('like', 'dislike', 'save', 'share', 'skip', 'add_to_playlist', 'rate', 'comment')),
    interaction_value INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Playlists
CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    playlist_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    follower_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Playlist content mapping
CREATE TABLE playlist_content (
    playlist_id INTEGER REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    content_id INTEGER REFERENCES content(content_id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, content_id)
);

-- Subscriptions and billing - for churn and revenue analytics
CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    plan_type VARCHAR(20) CHECK (plan_type IN ('free', 'premium', 'family', 'student')),
    billing_cycle VARCHAR(20) CHECK (billing_cycle IN ('monthly', 'yearly')),
    amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) CHECK (status IN ('active', 'cancelled', 'paused', 'expired', 'trial')),
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    cancellation_date DATE,
    cancellation_reason VARCHAR(100),
    discount_applied DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment transactions - for revenue tracking
CREATE TABLE payment_transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    subscription_id INTEGER REFERENCES subscriptions(subscription_id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50),
    transaction_status VARCHAR(20) CHECK (transaction_status IN ('success', 'failed', 'pending', 'refunded')),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    failure_reason VARCHAR(255)
);

-- User engagement metrics - daily snapshots
CREATE TABLE daily_user_metrics (
    metric_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    metric_date DATE NOT NULL,
    sessions_count INTEGER DEFAULT 0,
    total_watch_time_seconds INTEGER DEFAULT 0,
    unique_content_watched INTEGER DEFAULT 0,
    interactions_count INTEGER DEFAULT 0,
    login_count INTEGER DEFAULT 0,
    days_since_signup INTEGER,
    is_active BOOLEAN DEFAULT false,
    engagement_score DECIMAL(5,2),
    UNIQUE(user_id, metric_date)
);

-- Conversion funnel events - track user journey
CREATE TABLE funnel_events (
    event_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    session_id UUID,
    event_type VARCHAR(50) NOT NULL,
    event_step INTEGER NOT NULL,
    funnel_name VARCHAR(50) CHECK (funnel_name IN ('signup', 'subscription_upgrade', 'content_discovery', 'onboarding')),
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_properties JSONB,
    completed BOOLEAN DEFAULT false
);

-- A/B test experiments
CREATE TABLE experiments (
    experiment_id SERIAL PRIMARY KEY,
    experiment_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) CHECK (status IN ('draft', 'running', 'paused', 'completed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User experiment assignments
CREATE TABLE user_experiments (
    assignment_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    experiment_id INTEGER REFERENCES experiments(experiment_id),
    variant VARCHAR(50) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, experiment_id)
);

-- Content recommendations - track recommendation performance
CREATE TABLE content_recommendations (
    recommendation_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    content_id INTEGER REFERENCES content(content_id),
    recommendation_algorithm VARCHAR(50),
    recommendation_score DECIMAL(5,4),
    position_in_list INTEGER,
    context VARCHAR(100),
    recommended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    clicked BOOLEAN DEFAULT false,
    clicked_at TIMESTAMP,
    played BOOLEAN DEFAULT false,
    played_at TIMESTAMP
);

-- Search events - for content discovery analysis
CREATE TABLE search_events (
    search_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    session_id UUID,
    search_query VARCHAR(500) NOT NULL,
    results_count INTEGER,
    clicked_result_position INTEGER,
    clicked_content_id INTEGER REFERENCES content(content_id),
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    had_results BOOLEAN DEFAULT true
);

-- Notifications sent to users
CREATE TABLE notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    notification_type VARCHAR(50) CHECK (notification_type IN ('promotional', 'content_release', 'engagement', 're-engagement', 'billing')),
    channel VARCHAR(20) CHECK (channel IN ('email', 'push', 'sms', 'in-app')),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    opened BOOLEAN DEFAULT false,
    opened_at TIMESTAMP,
    clicked BOOLEAN DEFAULT false,
    clicked_at TIMESTAMP,
    converted BOOLEAN DEFAULT false,
    converted_at TIMESTAMP
);

-- Create indexes for analytics queries
CREATE INDEX idx_streaming_events_user_id ON streaming_events(user_id);
CREATE INDEX idx_streaming_events_content_id ON streaming_events(content_id);
CREATE INDEX idx_streaming_events_started_at ON streaming_events(started_at);
CREATE INDEX idx_streaming_events_session_id ON streaming_events(session_id);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_started_at ON user_sessions(started_at);
CREATE INDEX idx_user_interactions_user_id ON user_interactions(user_id);
CREATE INDEX idx_user_interactions_content_id ON user_interactions(content_id);
CREATE INDEX idx_user_interactions_created_at ON user_interactions(created_at);
CREATE INDEX idx_content_type ON content(content_type);
CREATE INDEX idx_content_genre ON content(genre);
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);
CREATE INDEX idx_users_country ON users(country);
CREATE INDEX idx_users_account_status ON users(account_status);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_payment_transactions_user_id ON payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_date ON payment_transactions(transaction_date);
CREATE INDEX idx_daily_metrics_user_date ON daily_user_metrics(user_id, metric_date);
CREATE INDEX idx_daily_metrics_date ON daily_user_metrics(metric_date);
CREATE INDEX idx_funnel_events_funnel ON funnel_events(funnel_name, event_step);
CREATE INDEX idx_funnel_events_user ON funnel_events(user_id);
CREATE INDEX idx_recommendations_user_id ON content_recommendations(user_id);
CREATE INDEX idx_recommendations_content_id ON content_recommendations(content_id);
CREATE INDEX idx_search_events_user_id ON search_events(user_id);
CREATE INDEX idx_search_events_searched_at ON search_events(searched_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);
