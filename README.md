# MCP Streaming Analytics Server

A Model Context Protocol (MCP) server for analyzing streaming platform data (music, video, podcasts) with advanced analytics capabilities including engagement tracking, churn analysis, funnel metrics, and cohort analysis.

## Features

### Data Model

The database includes realistic streaming platform data with:

- **Users**: subscription tiers, demographics, churn tracking
- **Content**: movies, series, songs, albums, podcasts
- **Streaming Events**: play history, completion rates, device/platform tracking
- **Engagement Metrics**: daily user activity, sessions, watch time
- **Subscriptions & Payments**: billing, revenue tracking
- **Funnel Events**: conversion tracking for signup, upgrades, etc.
- **A/B Tests**: experiment tracking and variant assignments
- **Recommendations**: recommendation performance tracking
- **Search & Notifications**: user interaction tracking

### MCP Tools

1. **query_users** - Query users with filters (subscription tier, country, status)
2. **analyze_engagement** - Analyze user engagement metrics over time
3. **content_performance** - Analyze content performance by type, genre, plays
4. **funnel_analysis** - Conversion funnel analysis (signup, upgrade, etc.)
5. **churn_prediction** - Identify at-risk users based on inactivity
6. **cohort_analysis** - Cohort retention and revenue analysis
7. **custom_query** - Execute custom SQL queries (SELECT only)

### MCP Resources

- `analytics://users/active` - Active users by tier
- `analytics://users/churn` - Churn analysis by reason
- `analytics://engagement/daily` - Daily engagement trends
- `analytics://content/popular` - Top performing content
- `analytics://revenue/summary` - Revenue trends by month

## Setup

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- PostgreSQL (via Docker)
- [uv](https://docs.astral.sh/uv/) (recommended) or `brew install uv`

### Installation

1. **Start the database**:

```bash
cd mcp-streaming-analytics
docker compose up -d
```

Wait for the database to initialize (check with `docker compose logs -f`).

2. **Create virtual environment and install dependencies**:

```bash
# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # macOS/Linux
# OR
.venv\Scripts\activate     # Windows

# Install dependencies
uv pip install -r requirements.txt
```

3. **Verify database connection**:

```bash
docker exec -it streaming-db psql -U streaming_user -d streaming_analytics -c "SELECT COUNT(*) FROM users;"
```

### Running the MCP Server

#### Development Mode

```bash
python src/server.py
```

#### With MCP Inspector (for testing)

```bash
npx @modelcontextprotocol/inspector python src/server.py
```

### Using with Claude Desktop

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "streaming-analytics": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/mcp-streaming-analytics",
        "run",
        "python",
        "src/server.py"
      ]
    }
  }
}
```

**Note**: Replace `/path/to/mcp-streaming-analytics` with your actual project path. Using `uv run` automatically manages the virtual environment. Database credentials are loaded automatically from the `.env` file.

## Example Queries

### Using Tools

**Find at-risk premium users**:

```
Use the churn_prediction tool with subscription_tier="premium" and days_threshold=7
```

**Analyze signup funnel**:

```
Use the funnel_analysis tool with funnel_name="signup"
```

**Get top performing content**:

```
Use the content_performance tool with content_type="series" and min_plays=2
```

**Cohort retention analysis**:

```
Use the cohort_analysis tool with cohort_month="2024-01" and metric="retention"
```

### Custom SQL Queries

**User engagement by country**:

```sql
SELECT
    u.country,
    COUNT(DISTINCT u.user_id) as users,
    AVG(m.engagement_score) as avg_engagement,
    SUM(m.total_watch_time_seconds)/3600 as total_hours
FROM users u
JOIN daily_user_metrics m ON u.user_id = m.user_id
WHERE m.metric_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY u.country
ORDER BY total_hours DESC
```

**Content binge-watching analysis**:

```sql
SELECT
    c.title,
    COUNT(*) as binge_sessions,
    AVG(se.duration_seconds/60) as avg_minutes_per_session
FROM streaming_events se
JOIN content c ON se.content_id = c.content_id
WHERE se.is_binge_watch = true
GROUP BY c.title
ORDER BY binge_sessions DESC
LIMIT 10
```

## Database Schema

Key tables:

- `users` - User accounts with subscription and churn info
- `content` - Streaming content catalog
- `streaming_events` - Playback events with completion tracking
- `user_sessions` - User session tracking
- `daily_user_metrics` - Daily engagement snapshots
- `subscriptions` - Subscription lifecycle
- `payment_transactions` - Revenue tracking
- `funnel_events` - Conversion funnel tracking
- `content_recommendations` - Recommendation performance
- `notifications` - Notification engagement

## Analytics Use Cases

1. **Engagement Analysis**: Track DAU/MAU, session duration, content consumption
2. **Churn Prediction**: Identify at-risk users, analyze churn reasons
3. **Content Performance**: Measure views, completion rates, popularity trends
4. **Funnel Optimization**: Analyze signup/upgrade conversion rates
5. **Cohort Analysis**: Track user retention and LTV by cohort
6. **Revenue Analytics**: Monitor MRR, ARPU, payment success rates
7. **A/B Testing**: Evaluate experiment impact on key metrics
8. **Recommendation Performance**: Track CTR and conversion of recommendations

## Development

### Add More Seed Data

Edit `database/seeds/01_seed_data.sql` and restart the database:

```bash
docker compose down -v
docker compose up -d
```

### Extend the MCP Server

Add new tools or resources in `src/server.py`:

- Tools: Add to `@mcp.list_tools()` and `@mcp.call_tool()`
- Resources: Add to `@mcp.list_resources()` and `@mcp.read_resource()`

## Troubleshooting

**Database connection issues**:

```bash
# Check if database is running
docker compose ps

# View logs
docker compose logs -f postgres

# Restart database
docker compose restart postgres
```

**Reset database**:

```bash
docker compose down -v
docker compose up -d
```

## License

MIT
