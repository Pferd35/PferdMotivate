-- Create missions table
CREATE TABLE IF NOT EXISTS missions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE missions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy to allow users to view only their own missions
CREATE POLICY "Users can view their own missions" ON missions
    FOR SELECT USING (auth.uid() = user_id);

-- Policy to allow users to insert their own missions
CREATE POLICY "Users can insert their own missions" ON missions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to update their own missions
CREATE POLICY "Users can update their own missions" ON missions
    FOR UPDATE USING (auth.uid() = user_id);

-- Policy to allow users to delete their own missions
CREATE POLICY "Users can delete their own missions" ON missions
    FOR DELETE USING (auth.uid() = user_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_missions_updated_at 
    BEFORE UPDATE ON missions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_missions_user_id ON missions(user_id);
CREATE INDEX IF NOT EXISTS idx_missions_created_at ON missions(created_at); 