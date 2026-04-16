-- Create table for tracking user notification status
CREATE TABLE IF NOT EXISTS user_notification_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  last_seen_tagihan TIMESTAMP WITH TIME ZONE,
  last_seen_info TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_notification_status_user_id ON user_notification_status(user_id);

-- Note: RLS is disabled since you're not using Supabase Auth
-- Make sure to handle security at the application level
