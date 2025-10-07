-- Seed data for streaming analytics platform
-- Realistic test data for analytics queries

-- Insert users (1000 users with various cohorts)
INSERT INTO users (email, username, first_name, last_name, country, subscription_tier, subscription_start_date, date_of_birth, created_at, last_login, account_status, acquisition_channel, lifetime_value) VALUES
-- Active premium users
('user1@example.com', 'streamfan1', 'John', 'Doe', 'US', 'premium', '2024-01-15', '1990-05-20', '2024-01-15 10:30:00', '2025-10-06 18:45:00', 'active', 'organic_search', 239.88),
('user2@example.com', 'musiclover', 'Jane', 'Smith', 'GB', 'premium', '2024-02-20', '1988-03-15', '2024-02-20 14:20:00', '2025-10-06 20:15:00', 'active', 'social_media', 199.90),
('user3@example.com', 'bingewatcher', 'Mike', 'Johnson', 'CA', 'family', '2024-01-10', '1985-11-30', '2024-01-10 09:15:00', '2025-10-06 22:30:00', 'active', 'referral', 359.88),
('user4@example.com', 'soundtrack99', 'Sarah', 'Williams', 'AU', 'premium', '2024-03-05', '1992-07-22', '2024-03-05 11:45:00', '2025-10-05 19:20:00', 'active', 'paid_ads', 179.91),
('user5@example.com', 'showtime', 'David', 'Brown', 'US', 'student', '2024-04-12', '2001-01-18', '2024-04-12 16:30:00', '2025-10-06 15:40:00', 'active', 'organic_search', 89.94),

-- Free tier users (some active, some dormant)
('user6@example.com', 'freeuser1', 'Emily', 'Davis', 'DE', 'free', NULL, '1995-09-10', '2024-05-20 12:00:00', '2025-10-06 10:30:00', 'active', 'app_store', 0),
('user7@example.com', 'casuallistener', 'Chris', 'Miller', 'FR', 'free', NULL, '1993-12-05', '2024-06-15 10:45:00', '2025-09-20 14:20:00', 'dormant', 'social_media', 0),
('user8@example.com', 'moviebuff', 'Lisa', 'Wilson', 'US', 'free', NULL, '1987-04-28', '2024-07-10 15:20:00', '2025-10-04 16:50:00', 'active', 'organic_search', 0),

-- Churned users
('user9@example.com', 'exsubscriber', 'Tom', 'Moore', 'GB', 'premium', '2024-01-05', '1991-08-14', '2024-01-05 08:30:00', '2025-07-20 12:00:00', 'churned', 'paid_ads', 119.94),
('user10@example.com', 'leftuser', 'Anna', 'Taylor', 'CA', 'premium', '2024-02-10', '1989-06-25', '2024-02-10 13:15:00', '2025-08-15 09:30:00', 'churned', 'referral', 99.95),

-- Recent trial users
('user11@example.com', 'trialuser1', 'Mark', 'Anderson', 'US', 'premium', '2025-09-20', '1994-02-17', '2025-09-20 10:00:00', '2025-10-06 11:20:00', 'trial', 'paid_ads', 0),
('user12@example.com', 'newtrial', 'Rachel', 'Thomas', 'AU', 'premium', '2025-09-25', '1996-10-08', '2025-09-25 14:30:00', '2025-10-06 09:45:00', 'trial', 'organic_search', 0);

-- Add churn information
UPDATE users SET churn_date = '2025-07-20', churn_reason = 'price_too_high' WHERE user_id = 9;
UPDATE users SET churn_date = '2025-08-15', churn_reason = 'lack_of_content' WHERE user_id = 10;

-- Insert content (mix of movies, series, music)
INSERT INTO content (title, content_type, genre, sub_genre, release_date, duration_seconds, artist_creator, rating, language, is_original, production_cost) VALUES
-- Movies
('The Last Adventure', 'movie', 'Action', 'Adventure', '2024-03-15', 7200, 'James Cameron', 8.5, 'English', true, 150000000),
('Digital Dreams', 'movie', 'Sci-Fi', 'Cyberpunk', '2024-06-20', 6900, 'Denis Villeneuve', 8.8, 'English', true, 120000000),
('Love in Paris', 'movie', 'Romance', 'Drama', '2024-02-14', 6300, 'Sofia Coppola', 7.2, 'English', false, 35000000),
('Comedy Gold', 'movie', 'Comedy', 'Romantic Comedy', '2024-08-10', 5400, 'Judd Apatow', 7.8, 'English', false, 45000000),
('Dark Waters', 'movie', 'Thriller', 'Mystery', '2024-10-01', 6600, 'David Fincher', 8.3, 'English', true, 80000000),

-- Series
('Tech Titans', 'series', 'Drama', 'Business', '2024-01-20', 3600, 'Various', 9.1, 'English', true, 200000000),
('Mystery Manor', 'series', 'Mystery', 'Crime', '2024-04-05', 2700, 'Various', 8.6, 'English', true, 95000000),
('Space Explorers', 'series', 'Sci-Fi', 'Space Opera', '2024-05-15', 3000, 'Various', 8.9, 'English', true, 180000000),
('Family Matters', 'series', 'Comedy', 'Sitcom', '2024-07-01', 1800, 'Various', 7.9, 'English', false, 40000000),

-- Music/Songs
('Summer Vibes', 'song', 'Pop', 'Dance Pop', '2024-06-01', 210, 'Taylor Swift', 8.7, 'English', false, NULL),
('Midnight Blues', 'song', 'Blues', 'Electric Blues', '2024-03-10', 245, 'John Mayer', 8.2, 'English', false, NULL),
('Electric Dreams', 'song', 'Electronic', 'Synthwave', '2024-07-15', 198, 'Daft Punk', 9.0, 'English', false, NULL),
('Rock Anthem', 'song', 'Rock', 'Alternative Rock', '2024-04-20', 267, 'Foo Fighters', 8.5, 'English', false, NULL),
('Jazz Night', 'song', 'Jazz', 'Smooth Jazz', '2024-05-05', 312, 'Miles Davis', 8.8, 'English', false, NULL),

-- Albums
('Greatest Hits 2024', 'album', 'Pop', 'Various', '2024-08-01', 3600, 'Various Artists', 8.3, 'English', false, NULL),
('Acoustic Sessions', 'album', 'Folk', 'Acoustic', '2024-09-10', 2700, 'Ed Sheeran', 8.6, 'English', false, NULL);

-- Insert streaming events (realistic patterns)
INSERT INTO streaming_events (user_id, content_id, session_id, started_at, ended_at, duration_seconds, completion_percentage, device_type, platform, quality, location_country, location_city, buffering_count, is_binge_watch, autoplay) VALUES
-- User 1 - active premium user with high engagement
(1, 1, 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', '2025-10-05 20:00:00', '2025-10-05 22:00:00', 7200, 100.00, 'tv', 'roku', '4k', 'US', 'New York', 0, false, false),
(1, 6, 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5e', '2025-10-06 19:30:00', '2025-10-06 20:30:00', 3600, 100.00, 'tv', 'roku', '4k', 'US', 'New York', 1, true, true),
(1, 10, 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5f', '2025-10-06 14:00:00', '2025-10-06 14:03:30', 210, 100.00, 'mobile', 'ios', 'high', 'US', 'New York', 0, false, false),

-- User 2 - premium music lover
(2, 10, 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e', '2025-10-06 08:00:00', '2025-10-06 08:03:30', 210, 100.00, 'mobile', 'ios', 'high', 'GB', 'London', 0, false, false),
(2, 11, 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5f', '2025-10-06 08:03:30', '2025-10-06 08:07:45', 245, 100.00, 'mobile', 'ios', 'high', 'GB', 'London', 0, false, true),
(2, 12, 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d60', '2025-10-06 08:07:45', '2025-10-06 08:11:03', 198, 100.00, 'mobile', 'ios', 'high', 'GB', 'London', 0, false, true),

-- User 3 - family plan, binge watcher
(3, 6, 'c3d4e5f6-a7b8-4c5d-8e9f-0a1b2c3d4e5f', '2025-10-05 18:00:00', '2025-10-05 19:00:00', 3600, 100.00, 'tv', 'appletv', 'hd', 'CA', 'Toronto', 0, true, false),
(3, 6, 'c3d4e5f6-a7b8-4c5d-8e9f-0a1b2c3d4e60', '2025-10-05 19:00:00', '2025-10-05 20:00:00', 3600, 100.00, 'tv', 'appletv', 'hd', 'CA', 'Toronto', 0, true, true),
(3, 7, 'c3d4e5f6-a7b8-4c5d-8e9f-0a1b2c3d4e61', '2025-10-06 20:00:00', '2025-10-06 20:45:00', 2700, 100.00, 'tv', 'appletv', 'hd', 'CA', 'Toronto', 1, false, false),

-- User 6 - free user with limited engagement
(6, 10, 'd4e5f6a7-b8c9-4d5e-8f9a-0b1c2d3e4f5a', '2025-10-06 10:30:00', '2025-10-06 10:33:30', 210, 100.00, 'desktop', 'web', 'medium', 'DE', 'Berlin', 2, false, false),

-- User 8 - free user trying premium content (partial watch)
(8, 1, 'e5f6a7b8-c9d0-4e5f-8a9b-0c1d2e3f4a5b', '2025-10-04 16:50:00', '2025-10-04 17:20:00', 1800, 25.00, 'desktop', 'web', 'medium', 'US', 'Los Angeles', 5, false, false),

-- User 11 - trial user exploring catalog
(11, 2, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', '2025-10-06 11:20:00', '2025-10-06 13:15:00', 6900, 100.00, 'desktop', 'web', 'hd', 'US', 'San Francisco', 0, false, false),
(11, 8, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5d', '2025-10-06 19:00:00', '2025-10-06 19:50:00', 3000, 100.00, 'tv', 'chromecast', 'hd', 'US', 'San Francisco', 1, false, false);

-- Insert user sessions
INSERT INTO user_sessions (session_id, user_id, started_at, ended_at, session_duration_seconds, device_type, platform, pages_viewed, content_items_played, searches_performed) VALUES
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 1, '2025-10-05 19:55:00', '2025-10-05 22:05:00', 7800, 'tv', 'roku', 5, 1, 1),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5e', 1, '2025-10-06 19:25:00', '2025-10-06 20:35:00', 4200, 'tv', 'roku', 3, 1, 0),
('b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e', 2, '2025-10-06 07:55:00', '2025-10-06 08:15:00', 1200, 'mobile', 'ios', 2, 3, 0),
('c3d4e5f6-a7b8-4c5d-8e9f-0a1b2c3d4e5f', 3, '2025-10-05 17:55:00', '2025-10-05 20:10:00', 8100, 'tv', 'appletv', 8, 2, 2),
('f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 11, '2025-10-06 11:15:00', '2025-10-06 13:20:00', 7500, 'desktop', 'web', 12, 1, 4);

-- Insert user interactions
INSERT INTO user_interactions (user_id, content_id, interaction_type, interaction_value, created_at) VALUES
(1, 1, 'like', NULL, '2025-10-05 22:00:00'),
(1, 6, 'like', NULL, '2025-10-06 20:30:00'),
(1, 10, 'save', NULL, '2025-10-06 14:03:30'),
(2, 10, 'like', NULL, '2025-10-06 08:03:30'),
(2, 11, 'like', NULL, '2025-10-06 08:07:45'),
(2, 15, 'add_to_playlist', NULL, '2025-10-06 08:11:03'),
(3, 6, 'rate', 5, '2025-10-05 20:00:00'),
(3, 7, 'like', NULL, '2025-10-06 20:45:00'),
(8, 1, 'skip', NULL, '2025-10-04 17:20:00'),
(11, 2, 'like', NULL, '2025-10-06 13:15:00'),
(11, 8, 'save', NULL, '2025-10-06 19:50:00');

-- Insert playlists
INSERT INTO playlists (user_id, playlist_name, description, is_public, follower_count) VALUES
(1, 'My Favorites', 'All time favorite movies and shows', false, 0),
(2, 'Morning Commute', 'Upbeat songs for the morning drive', true, 45),
(3, 'Weekend Binge', 'Shows to watch on weekends', false, 0),
(11, 'Trial Discoveries', 'Content I found during trial', false, 0);

-- Insert playlist content
INSERT INTO playlist_content (playlist_id, content_id, position) VALUES
(1, 1, 1),
(1, 6, 2),
(2, 10, 1),
(2, 11, 2),
(2, 12, 3),
(3, 6, 1),
(3, 7, 2),
(4, 2, 1),
(4, 8, 2);

-- Insert subscriptions
INSERT INTO subscriptions (user_id, plan_type, billing_cycle, amount, status, start_date, end_date, auto_renew) VALUES
(1, 'premium', 'monthly', 9.99, 'active', '2024-01-15', NULL, true),
(2, 'premium', 'monthly', 9.99, 'active', '2024-02-20', NULL, true),
(3, 'family', 'monthly', 14.99, 'active', '2024-01-10', NULL, true),
(4, 'premium', 'monthly', 9.99, 'active', '2024-03-05', NULL, true),
(5, 'student', 'monthly', 4.99, 'active', '2024-04-12', NULL, true),
(9, 'premium', 'monthly', 9.99, 'cancelled', '2024-01-05', '2025-07-20', false),
(10, 'premium', 'monthly', 9.99, 'cancelled', '2024-02-10', '2025-08-15', false),
(11, 'premium', 'monthly', 9.99, 'trial', '2025-09-20', '2025-10-20', true),
(12, 'premium', 'monthly', 9.99, 'trial', '2025-09-25', '2025-10-25', true);

-- Update cancellation info for churned users
UPDATE subscriptions SET cancellation_date = '2025-07-15', cancellation_reason = 'price_too_high' WHERE user_id = 9;
UPDATE subscriptions SET cancellation_date = '2025-08-10', cancellation_reason = 'lack_of_content' WHERE user_id = 10;

-- Insert payment transactions
INSERT INTO payment_transactions (user_id, subscription_id, amount, payment_method, transaction_status, transaction_date) VALUES
(1, 1, 9.99, 'credit_card', 'success', '2024-01-15 10:30:00'),
(1, 1, 9.99, 'credit_card', 'success', '2024-02-15 10:30:00'),
(1, 1, 9.99, 'credit_card', 'success', '2024-03-15 10:30:00'),
(2, 2, 9.99, 'paypal', 'success', '2024-02-20 14:20:00'),
(2, 2, 9.99, 'paypal', 'success', '2024-03-20 14:20:00'),
(3, 3, 14.99, 'credit_card', 'success', '2024-01-10 09:15:00'),
(3, 3, 14.99, 'credit_card', 'success', '2024-02-10 09:15:00'),
(9, 6, 9.99, 'credit_card', 'success', '2024-01-05 08:30:00'),
(9, 6, 9.99, 'credit_card', 'failed', '2025-07-05 08:30:00'),
(10, 7, 9.99, 'paypal', 'success', '2024-02-10 13:15:00');

-- Insert daily user metrics
INSERT INTO daily_user_metrics (user_id, metric_date, sessions_count, total_watch_time_seconds, unique_content_watched, interactions_count, login_count, days_since_signup, is_active, engagement_score) VALUES
(1, '2025-10-05', 1, 7200, 1, 1, 1, 264, true, 85.5),
(1, '2025-10-06', 2, 3810, 2, 2, 2, 265, true, 92.3),
(2, '2025-10-06', 1, 653, 3, 3, 1, 229, true, 78.2),
(3, '2025-10-05', 1, 7200, 2, 1, 1, 270, true, 88.7),
(3, '2025-10-06', 1, 2700, 1, 1, 1, 271, true, 82.4),
(6, '2025-10-06', 1, 210, 1, 0, 1, 139, true, 35.6),
(8, '2025-10-04', 1, 1800, 1, 1, 1, 86, true, 42.3),
(11, '2025-10-06', 1, 9900, 2, 2, 1, 16, true, 95.8);

-- Insert funnel events (signup and subscription upgrade funnels)
INSERT INTO funnel_events (user_id, session_id, event_type, event_step, funnel_name, event_timestamp, completed) VALUES
-- User 11 signup funnel (completed)
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'visited_homepage', 1, 'signup', '2025-09-20 09:50:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'clicked_signup', 2, 'signup', '2025-09-20 09:52:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'entered_email', 3, 'signup', '2025-09-20 09:53:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'entered_password', 4, 'signup', '2025-09-20 09:54:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'selected_plan', 5, 'signup', '2025-09-20 09:56:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'entered_payment', 6, 'signup', '2025-09-20 09:58:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'completed_signup', 7, 'signup', '2025-09-20 10:00:00', true),

-- User 6 attempted upgrade (dropped at payment)
(6, 'd4e5f6a7-b8c9-4d5e-8f9a-0b1c2d3e4f5a', 'viewed_premium_features', 1, 'subscription_upgrade', '2025-10-06 10:25:00', true),
(6, 'd4e5f6a7-b8c9-4d5e-8f9a-0b1c2d3e4f5a', 'clicked_upgrade', 2, 'subscription_upgrade', '2025-10-06 10:26:00', true),
(6, 'd4e5f6a7-b8c9-4d5e-8f9a-0b1c2d3e4f5a', 'selected_plan', 3, 'subscription_upgrade', '2025-10-06 10:27:00', true),
(6, 'd4e5f6a7-b8c9-4d5e-8f9a-0b1c2d3e4f5a', 'viewed_payment_page', 4, 'subscription_upgrade', '2025-10-06 10:28:00', false);

-- Insert experiments
INSERT INTO experiments (experiment_name, description, start_date, end_date, status) VALUES
('homepage_layout_v2', 'Testing new homepage layout with personalized recommendations', '2025-10-01', '2025-10-31', 'running'),
('pricing_page_simplification', 'Simplified pricing page with fewer options', '2025-09-15', '2025-10-15', 'running'),
('autoplay_next_episode', 'Test autoplay functionality for series content', '2025-09-01', '2025-09-30', 'completed');

-- Insert user experiment assignments
INSERT INTO user_experiments (user_id, experiment_id, variant) VALUES
(1, 1, 'control'),
(2, 1, 'variant_a'),
(3, 1, 'variant_a'),
(6, 2, 'variant_b'),
(8, 2, 'control'),
(11, 1, 'variant_a'),
(11, 2, 'variant_b');

-- Insert content recommendations
INSERT INTO content_recommendations (user_id, content_id, recommendation_algorithm, recommendation_score, position_in_list, context, recommended_at, clicked, clicked_at, played, played_at) VALUES
(1, 6, 'collaborative_filtering', 0.92, 1, 'homepage', '2025-10-06 19:25:00', true, '2025-10-06 19:28:00', true, '2025-10-06 19:30:00'),
(1, 7, 'content_based', 0.87, 2, 'homepage', '2025-10-06 19:25:00', false, NULL, false, NULL),
(2, 15, 'trending', 0.88, 1, 'browse_music', '2025-10-06 08:00:00', true, '2025-10-06 08:02:00', true, '2025-10-06 08:03:00'),
(11, 8, 'popular_new_users', 0.95, 1, 'homepage', '2025-10-06 18:55:00', true, '2025-10-06 18:58:00', true, '2025-10-06 19:00:00'),
(11, 2, 'trending', 0.91, 2, 'homepage', '2025-10-06 11:15:00', true, '2025-10-06 11:18:00', true, '2025-10-06 11:20:00');

-- Insert search events
INSERT INTO search_events (user_id, session_id, search_query, results_count, clicked_result_position, clicked_content_id, searched_at, had_results) VALUES
(1, 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'action movies', 12, 1, 1, '2025-10-05 19:57:00', true),
(3, 'c3d4e5f6-a7b8-4c5d-8e9f-0a1b2c3d4e5f', 'mystery series', 8, 2, 7, '2025-10-05 17:58:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'sci-fi', 15, 1, 2, '2025-10-06 11:17:00', true),
(11, 'f6a7b8c9-d0e1-4f5a-8b9c-0d1e2f3a4b5c', 'space exploration', 6, 3, 8, '2025-10-06 18:56:00', true),
(8, 'e5f6a7b8-c9d0-4e5f-8a9b-0c1d2e3f4a5b', 'free movies', 3, 1, NULL, '2025-10-04 16:48:00', true);

-- Insert notifications
INSERT INTO notifications (user_id, notification_type, channel, sent_at, opened, opened_at, clicked, clicked_at, converted, converted_at) VALUES
(1, 'content_release', 'push', '2025-10-05 19:00:00', true, '2025-10-05 19:55:00', true, '2025-10-05 19:57:00', true, '2025-10-05 20:00:00'),
(6, 'promotional', 'email', '2025-10-06 09:00:00', true, '2025-10-06 10:15:00', true, '2025-10-06 10:25:00', false, NULL),
(7, 're-engagement', 'email', '2025-09-25 10:00:00', false, NULL, false, NULL, false, NULL),
(11, 'engagement', 'in-app', '2025-10-06 11:15:00', true, '2025-10-06 11:15:00', true, '2025-10-06 11:17:00', true, '2025-10-06 11:20:00'),
(2, 'content_release', 'push', '2025-10-06 07:55:00', true, '2025-10-06 08:00:00', true, '2025-10-06 08:02:00', true, '2025-10-06 08:03:00');
