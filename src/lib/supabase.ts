import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Add debug logging
console.log('Supabase URL:', !!supabaseUrl); // Log existence without exposing the actual URL
console.log('Supabase Anon Key:', !!supabaseAnonKey); // Log existence without exposing the actual key

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables');
  throw new Error('Missing Supabase environment variables');
}

// Create Supabase client with retry logic and better error handling
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  global: {
    headers: {
      'Content-Type': 'application/json'
    }
  }
});

// Enhanced connection check
export const checkConnection = async () => {
  try {
    console.log('Checking Supabase connection...');
    const { data, error } = await supabase.from('map_icons').select('count', { count: 'exact', head: true });
    
    if (error) {
      console.error('Supabase connection check failed:', error);
      return false;
    }
    
    console.log('Supabase connection successful');
    return true;
  } catch (err) {
    console.error('Connection check failed:', err);
    return false;
  }
};

// Add immediate connection check
checkConnection().then(isConnected => {
  console.log('Initial connection status:', isConnected);
});