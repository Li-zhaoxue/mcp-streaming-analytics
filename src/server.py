#!/usr/bin/env python3
"""
MCP Server for Streaming Analytics
Provides tools and resources for analyzing streaming platform data
"""

import os
import sys
import asyncio
from pathlib import Path
from typing import Any, Optional
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

from mcp.server import Server
from mcp.types import Tool, TextContent, Resource, ResourceTemplate
from mcp.server.stdio import stdio_server

# Load environment variables from .env file in project root
# env_path = './.env'
# load_dotenv(dotenv_path=env_path, override=True)

# Database configuration - hardcoded defaults for local development
# Override these with environment variables in production
DB_CONFIG = {
    "host": "127.0.0.1",  # Use IPv4 explicitly instead of localhost
    "port": 5432,
    "database": "streaming_analytics",
    "user": "streaming_user",
    "password": "streaming_pass",
}


class DatabaseConnection:
    """Database connection manager"""

    def __init__(self, config: dict):
        self.config = config
        self.conn = None

    def connect(self):
        """Establish database connection"""
        if not self.conn or self.conn.closed:
            self.conn = psycopg2.connect(**self.config)
        return self.conn

    def execute_query(self, query: str, params: Optional[tuple] = None) -> list[dict]:
        """Execute a query and return results as list of dicts"""
        try:
            conn = self.connect()
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, params)
                if cur.description:
                    return [dict(row) for row in cur.fetchall()]
                conn.commit()
                return []
        except Exception as e:
            raise Exception(f"Database error: {str(e)}. Config: host={self.config['host']}, db={self.config['database']}, user={self.config['user']}")

    def close(self):
        """Close database connection"""
        if self.conn and not self.conn.closed:
            self.conn.close()


# Initialize database connection
db = DatabaseConnection(DB_CONFIG)

# Initialize MCP server
mcp = Server("mcp-streaming-analytics")


@mcp.list_resources()
async def list_resources() -> list[Resource]:
    """List available analytics resources"""
    return [
        Resource(
            uri="analytics://users/active",
            name="Active Users",
            description="Get active users count and details",
            mimeType="application/json"
        ),
        Resource(
            uri="analytics://users/churn",
            name="Churned Users",
            description="Get churned users analysis",
            mimeType="application/json"
        ),
        Resource(
            uri="analytics://engagement/daily",
            name="Daily Engagement Metrics",
            description="Get daily user engagement metrics",
            mimeType="application/json"
        ),
        Resource(
            uri="analytics://content/popular",
            name="Popular Content",
            description="Get most popular content",
            mimeType="application/json"
        ),
        Resource(
            uri="analytics://revenue/summary",
            name="Revenue Summary",
            description="Get revenue summary and trends",
            mimeType="application/json"
        ),
    ]


@mcp.read_resource()
async def read_resource(uri: str) -> str:
    """Read analytics resource data"""

    if uri == "analytics://users/active":
        query = """
            SELECT
                account_status,
                subscription_tier,
                COUNT(*) as user_count,
                AVG(lifetime_value) as avg_ltv
            FROM users
            WHERE account_status = 'active'
            GROUP BY account_status, subscription_tier
            ORDER BY user_count DESC
        """
        results = db.execute_query(query)
        return str(results)

    elif uri == "analytics://users/churn":
        query = """
            SELECT
                churn_reason,
                COUNT(*) as churn_count,
                AVG(EXTRACT(DAY FROM (churn_date - created_at))) as avg_days_before_churn
            FROM users
            WHERE account_status = 'churned'
            GROUP BY churn_reason
        """
        results = db.execute_query(query)
        return str(results)

    elif uri == "analytics://engagement/daily":
        query = """
            SELECT
                metric_date,
                COUNT(DISTINCT user_id) as active_users,
                SUM(sessions_count) as total_sessions,
                AVG(total_watch_time_seconds) as avg_watch_time,
                AVG(engagement_score) as avg_engagement_score
            FROM daily_user_metrics
            WHERE metric_date >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY metric_date
            ORDER BY metric_date DESC
        """
        results = db.execute_query(query)
        return str(results)

    elif uri == "analytics://content/popular":
        query = """
            SELECT
                c.title,
                c.content_type,
                c.genre,
                COUNT(se.event_id) as play_count,
                AVG(se.completion_percentage) as avg_completion,
                COUNT(DISTINCT se.user_id) as unique_viewers
            FROM content c
            JOIN streaming_events se ON c.content_id = se.content_id
            GROUP BY c.content_id, c.title, c.content_type, c.genre
            ORDER BY play_count DESC
            LIMIT 10
        """
        results = db.execute_query(query)
        return str(results)

    elif uri == "analytics://revenue/summary":
        query = """
            SELECT
                DATE_TRUNC('month', transaction_date) as month,
                COUNT(*) as transaction_count,
                SUM(amount) as total_revenue,
                COUNT(DISTINCT user_id) as paying_users
            FROM payment_transactions
            WHERE transaction_status = 'success'
            GROUP BY DATE_TRUNC('month', transaction_date)
            ORDER BY month DESC
            LIMIT 6
        """
        results = db.execute_query(query)
        return str(results)

    else:
        return "Resource not found"


@mcp.list_tools()
async def list_tools() -> list[Tool]:
    """List available analytics tools"""
    return [
        Tool(
            name="query_users",
            description="Query users with filters for subscription tier, country, or status",
            inputSchema={
                "type": "object",
                "properties": {
                    "subscription_tier": {
                        "type": "string",
                        "enum": ["free", "premium", "family", "student"],
                        "description": "Filter by subscription tier"
                    },
                    "country": {
                        "type": "string",
                        "description": "Filter by country code (e.g., US, GB)"
                    },
                    "account_status": {
                        "type": "string",
                        "enum": ["active", "churned", "dormant", "trial"],
                        "description": "Filter by account status"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of results",
                        "default": 100
                    }
                }
            }
        ),
        Tool(
            name="analyze_engagement",
            description="Analyze user engagement metrics for a specific user or time period",
            inputSchema={
                "type": "object",
                "properties": {
                    "user_id": {
                        "type": "integer",
                        "description": "Specific user ID to analyze"
                    },
                    "start_date": {
                        "type": "string",
                        "description": "Start date (YYYY-MM-DD)"
                    },
                    "end_date": {
                        "type": "string",
                        "description": "End date (YYYY-MM-DD)"
                    }
                }
            }
        ),
        Tool(
            name="content_performance",
            description="Analyze content performance metrics",
            inputSchema={
                "type": "object",
                "properties": {
                    "content_type": {
                        "type": "string",
                        "enum": ["movie", "series", "song", "album", "podcast"],
                        "description": "Filter by content type"
                    },
                    "genre": {
                        "type": "string",
                        "description": "Filter by genre"
                    },
                    "min_plays": {
                        "type": "integer",
                        "description": "Minimum number of plays",
                        "default": 0
                    }
                }
            }
        ),
        Tool(
            name="funnel_analysis",
            description="Analyze conversion funnel metrics",
            inputSchema={
                "type": "object",
                "properties": {
                    "funnel_name": {
                        "type": "string",
                        "enum": ["signup", "subscription_upgrade", "content_discovery", "onboarding"],
                        "description": "The funnel to analyze"
                    },
                    "start_date": {
                        "type": "string",
                        "description": "Start date (YYYY-MM-DD)"
                    },
                    "end_date": {
                        "type": "string",
                        "description": "End date (YYYY-MM-DD)"
                    }
                },
                "required": ["funnel_name"]
            }
        ),
        Tool(
            name="churn_prediction",
            description="Identify users at risk of churning based on engagement patterns",
            inputSchema={
                "type": "object",
                "properties": {
                    "days_threshold": {
                        "type": "integer",
                        "description": "Days of inactivity to consider at-risk",
                        "default": 7
                    },
                    "subscription_tier": {
                        "type": "string",
                        "enum": ["premium", "family", "student"],
                        "description": "Filter by subscription tier"
                    }
                }
            }
        ),
        Tool(
            name="cohort_analysis",
            description="Perform cohort analysis based on signup date",
            inputSchema={
                "type": "object",
                "properties": {
                    "cohort_month": {
                        "type": "string",
                        "description": "Cohort month (YYYY-MM)"
                    },
                    "metric": {
                        "type": "string",
                        "enum": ["retention", "revenue", "engagement"],
                        "description": "Metric to analyze",
                        "default": "retention"
                    }
                }
            }
        ),
        Tool(
            name="custom_query",
            description="Execute a custom SQL query for advanced analytics",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "SQL query to execute (SELECT only)"
                    }
                },
                "required": ["query"]
            }
        )
    ]


@mcp.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Execute analytics tool"""

    try:
        if name == "query_users":
            conditions = []
            params = []

            if "subscription_tier" in arguments:
                conditions.append("subscription_tier = %s")
                params.append(arguments["subscription_tier"])

            if "country" in arguments:
                conditions.append("country = %s")
                params.append(arguments["country"])

            if "account_status" in arguments:
                conditions.append("account_status = %s")
                params.append(arguments["account_status"])

            where_clause = " AND ".join(conditions) if conditions else "1=1"
            limit = arguments.get("limit", 100)

            query = f"""
                SELECT
                    user_id, username, email, country,
                    subscription_tier, account_status,
                    created_at, last_login, lifetime_value
                FROM users
                WHERE {where_clause}
                ORDER BY created_at DESC
                LIMIT %s
            """
            params.append(limit)

            results = db.execute_query(query, tuple(params))
            return [TextContent(type="text", text=str(results))]

        elif name == "analyze_engagement":
            conditions = []
            params = []

            if "user_id" in arguments:
                conditions.append("user_id = %s")
                params.append(arguments["user_id"])

            if "start_date" in arguments:
                conditions.append("metric_date >= %s")
                params.append(arguments["start_date"])

            if "end_date" in arguments:
                conditions.append("metric_date <= %s")
                params.append(arguments["end_date"])

            where_clause = " AND ".join(conditions) if conditions else "1=1"

            query = f"""
                SELECT
                    user_id,
                    metric_date,
                    sessions_count,
                    total_watch_time_seconds,
                    unique_content_watched,
                    interactions_count,
                    engagement_score,
                    is_active
                FROM daily_user_metrics
                WHERE {where_clause}
                ORDER BY metric_date DESC
            """

            results = db.execute_query(
                query, tuple(params) if params else None)
            return [TextContent(type="text", text=str(results))]

        elif name == "content_performance":
            conditions = []
            params = []

            if "content_type" in arguments:
                conditions.append("c.content_type = %s")
                params.append(arguments["content_type"])

            if "genre" in arguments:
                conditions.append("c.genre = %s")
                params.append(arguments["genre"])

            min_plays = arguments.get("min_plays", 0)

            where_clause = " AND ".join(conditions) if conditions else "1=1"

            query = f"""
                SELECT
                    c.content_id,
                    c.title,
                    c.content_type,
                    c.genre,
                    c.artist_creator,
                    COUNT(se.event_id) as total_plays,
                    COUNT(DISTINCT se.user_id) as unique_viewers,
                    AVG(se.completion_percentage) as avg_completion_rate,
                    AVG(se.duration_seconds) as avg_watch_duration,
                    SUM(CASE WHEN se.completion_percentage >= 80 THEN 1 ELSE 0 END) as completed_plays
                FROM content c
                LEFT JOIN streaming_events se ON c.content_id = se.content_id
                WHERE {where_clause}
                GROUP BY c.content_id, c.title, c.content_type, c.genre, c.artist_creator
                HAVING COUNT(se.event_id) >= %s
                ORDER BY total_plays DESC
            """
            params.append(min_plays)

            results = db.execute_query(query, tuple(params))
            return [TextContent(type="text", text=str(results))]

        elif name == "funnel_analysis":
            funnel_name = arguments["funnel_name"]
            conditions = ["funnel_name = %s"]
            params = [funnel_name]

            if "start_date" in arguments:
                conditions.append("event_timestamp >= %s")
                params.append(arguments["start_date"])

            if "end_date" in arguments:
                conditions.append("event_timestamp <= %s")
                params.append(arguments["end_date"])

            where_clause = " AND ".join(conditions)

            query = f"""
                WITH funnel_steps AS (
                    SELECT
                        event_step,
                        event_type,
                        COUNT(DISTINCT user_id) as users_at_step,
                        COUNT(DISTINCT CASE WHEN completed THEN user_id END) as users_completed
                    FROM funnel_events
                    WHERE {where_clause}
                    GROUP BY event_step, event_type
                    ORDER BY event_step
                )
                SELECT
                    event_step,
                    event_type,
                    users_at_step,
                    users_completed,
                    ROUND(100.0 * users_completed / NULLIF(users_at_step, 0), 2) as completion_rate,
                    LAG(users_at_step) OVER (ORDER BY event_step) as previous_step_users,
                    CASE
                        WHEN LAG(users_at_step) OVER (ORDER BY event_step) IS NOT NULL
                        THEN ROUND(100.0 * users_at_step / LAG(users_at_step) OVER (ORDER BY event_step), 2)
                    END as conversion_rate
                FROM funnel_steps
            """

            results = db.execute_query(query, tuple(params))
            return [TextContent(type="text", text=str(results))]

        elif name == "churn_prediction":
            days_threshold = arguments.get("days_threshold", 7)
            conditions = ["u.account_status = 'active'"]
            params = [days_threshold]

            if "subscription_tier" in arguments:
                conditions.append("u.subscription_tier = %s")
                params.append(arguments["subscription_tier"])

            where_clause = " AND ".join(conditions)

            query = f"""
                SELECT
                    u.user_id,
                    u.username,
                    u.email,
                    u.subscription_tier,
                    u.last_login,
                    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - u.last_login)) as days_inactive,
                    COALESCE(recent.avg_engagement, 0) as recent_engagement_score,
                    COALESCE(recent.sessions_last_week, 0) as sessions_last_week
                FROM users u
                LEFT JOIN (
                    SELECT
                        user_id,
                        AVG(engagement_score) as avg_engagement,
                        SUM(sessions_count) as sessions_last_week
                    FROM daily_user_metrics
                    WHERE metric_date >= CURRENT_DATE - INTERVAL '7 days'
                    GROUP BY user_id
                ) recent ON u.user_id = recent.user_id
                WHERE {where_clause}
                    AND EXTRACT(DAY FROM (CURRENT_TIMESTAMP - u.last_login)) >= %s
                ORDER BY days_inactive DESC, recent_engagement_score ASC
            """

            results = db.execute_query(query, tuple(params))
            return [TextContent(type="text", text=str(results))]

        elif name == "cohort_analysis":
            cohort_month = arguments.get("cohort_month")
            metric = arguments.get("metric", "retention")

            if metric == "retention":
                query = """
                    WITH cohort_users AS (
                        SELECT
                            user_id,
                            DATE_TRUNC('month', created_at) as cohort_month
                        FROM users
                        WHERE DATE_TRUNC('month', created_at) = %s::date
                    ),
                    cohort_activity AS (
                        SELECT
                            cu.cohort_month,
                            DATE_TRUNC('month', dum.metric_date) as activity_month,
                            COUNT(DISTINCT dum.user_id) as active_users,
                            COUNT(DISTINCT cu.user_id) as cohort_size
                        FROM cohort_users cu
                        LEFT JOIN daily_user_metrics dum ON cu.user_id = dum.user_id
                        GROUP BY cu.cohort_month, DATE_TRUNC('month', dum.metric_date)
                    )
                    SELECT
                        cohort_month,
                        activity_month,
                        active_users,
                        cohort_size,
                        ROUND(100.0 * active_users / cohort_size, 2) as retention_rate,
                        EXTRACT(MONTH FROM AGE(activity_month, cohort_month)) as months_since_signup
                    FROM cohort_activity
                    WHERE activity_month IS NOT NULL
                    ORDER BY activity_month
                """
                params = (cohort_month,)
            else:
                query = "SELECT 'Metric not yet implemented' as message"
                params = None

            results = db.execute_query(query, params)
            return [TextContent(type="text", text=str(results))]

        elif name == "custom_query":
            query = arguments["query"].strip()

            # Security check - only allow SELECT queries
            if not query.upper().startswith("SELECT"):
                return [TextContent(type="text", text="Error: Only SELECT queries are allowed")]

            # Prevent multiple statements
            if ";" in query[:-1]:  # Allow trailing semicolon
                return [TextContent(type="text", text="Error: Multiple statements not allowed")]

            results = db.execute_query(query)
            return [TextContent(type="text", text=str(results))]

        else:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

    except Exception as e:
        return [TextContent(type="text", text=f"Error executing tool: {str(e)}")]


async def main():
    """Run the MCP server"""
    async with stdio_server() as (read_stream, write_stream):
        await mcp.run(
            read_stream,
            write_stream,
            mcp.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
