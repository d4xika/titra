import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://ztsjbrifuxpsdlvylmhn.supabase.co"
const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0c2picmlmdXhwc2RsdnlsbWhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MzYxMjYsImV4cCI6MjA3MjQxMjEyNn0.xuf7a743SyXFMgGQVHy2DfOzaHiiogkhsNUNaBGFEqY"

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export async function saveSession(start_time, duration, description, project_name){

    const user_id = JSON.parse(localStorage.getItem('user')).id

    const { data } = await supabase
        .from('projects')
        .select('id')
        .eq('name', project_name)

    const response = await supabase
        .from('sessions')
        .insert({start_time: start_time, duration: duration, description: description, user_id: user_id, project_id: data.id  })
        .select('id')
    return response.data[0].id
}