import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://ztsjbrifuxpsdlvylmhn.supabase.co"
const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0c2picmlmdXhwc2RsdnlsbWhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MzYxMjYsImV4cCI6MjA3MjQxMjEyNn0.xuf7a743SyXFMgGQVHy2DfOzaHiiogkhsNUNaBGFEqY"

export const supabase = createClient(supabaseUrl, supabaseAnonKey)