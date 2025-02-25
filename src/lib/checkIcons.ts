import { supabase } from './supabase';

export async function checkIcons() {
  try {
    // List all files in the icons bucket
    const { data: files, error } = await supabase.storage
      .from('icons')
      .list();

    if (error) {
      console.error('Error checking icons:', error);
      return {
        success: false,
        error: error.message,
        files: []
      };
    }

    // Get database records for comparison
    const { data: iconRecords, error: dbError } = await supabase
      .from('map_icons')
      .select('*');

    if (dbError) {
      console.error('Error checking icon records:', dbError);
      return {
        success: false,
        error: dbError.message,
        files: files || []
      };
    }

    return {
      success: true,
      files: files || [],
      databaseRecords: iconRecords || []
    };
  } catch (error) {
    console.error('Unexpected error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      files: []
    };
  }
}