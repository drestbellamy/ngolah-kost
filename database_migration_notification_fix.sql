-- Migration: Fix notification tracking to store separate IDs for pengumuman and peraturan
-- Date: 2026-04-29
-- Description: Add separate columns for tracking last seen pengumuman and peraturan

-- Check if columns exist and add them if not
DO $$ 
BEGIN
    -- Add last_seen_pengumuman column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_notification_status' 
        AND column_name = 'last_seen_pengumuman'
    ) THEN
        ALTER TABLE user_notification_status 
        ADD COLUMN last_seen_pengumuman TEXT;
    END IF;

    -- Add last_seen_peraturan column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_notification_status' 
        AND column_name = 'last_seen_peraturan'
    ) THEN
        ALTER TABLE user_notification_status 
        ADD COLUMN last_seen_peraturan TEXT;
    END IF;

    -- Migrate data from old last_seen_info column if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_notification_status' 
        AND column_name = 'last_seen_info'
    ) THEN
        -- Copy last_seen_info to last_seen_pengumuman (as fallback)
        UPDATE user_notification_status 
        SET last_seen_pengumuman = last_seen_info 
        WHERE last_seen_info IS NOT NULL 
        AND last_seen_pengumuman IS NULL;
    END IF;
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_notification_status_user_id 
ON user_notification_status(user_id);

-- Add foreign key constraint if not exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_user_notification_status_user_id'
    ) THEN
        ALTER TABLE user_notification_status
        ADD CONSTRAINT fk_user_notification_status_user_id
        FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'user_notification_status'
ORDER BY ordinal_position;
