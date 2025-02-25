import { supabase } from './supabase';

interface QueryResult {
  data: any[] | null;
  error: string | null;
  count: number | null;
}

interface CareSettingEncounter {
  id: string;
  care_setting: string;
  systems_of_care: string;
  icd_family_code: string;
  encounters: number;
  created_at: string;
}

export async function fetchCareSettingsEncounters(): Promise<QueryResult> {
  try {
    // Perform the query with error handling
    const { data, error, count } = await supabase
      .from('care_settings_encounters')
      .select('*', { count: 'exact' })
      .order('care_setting', { ascending: true })
      .limit(1000);

    if (error) {
      // Handle specific error types
      if (error.code === '42P01') {
        return {
          data: null,
          error: 'Table does not exist',
          count: null
        };
      }
      if (error.code === 'PGRST301') {
        return {
          data: null,
          error: 'Database connection failed',
          count: null
        };
      }
      if (error.code === '42501') {
        return {
          data: null,
          error: 'Authentication failed - insufficient permissions',
          count: null
        };
      }
      if (error.code === '3D000') {
        return {
          data: null,
          error: 'Database does not exist',
          count: null
        };
      }
      
      // Generic error handling
      return {
        data: null,
        error: `Database error: ${error.message}`,
        count: null
      };
    }

    return {
      data: data as CareSettingEncounter[],
      error: null,
      count: count || 0
    };
  } catch (err) {
    // Handle unexpected errors
    console.error('Unexpected error:', err);
    return {
      data: null,
      error: 'An unexpected error occurred',
      count: null
    };
  }
}

// Function to get care settings data with retry logic
export async function getCareSettingsData(retries = 3): Promise<CareSettingEncounter[] | null> {
  try {
    // Validate environment variables
    if (!import.meta.env.VITE_SUPABASE_URL || !import.meta.env.VITE_SUPABASE_ANON_KEY) {
      throw new Error('Missing required environment variables');
    }

    let attempt = 0;
    while (attempt < retries) {
      const result = await fetchCareSettingsEncounters();

      if (result.data) {
        return result.data;
      }

      if (result.error && result.error !== 'Database connection failed') {
        console.error('Error fetching care settings data:', result.error);
        return null;
      }

      // Wait before retrying (exponential backoff)
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
      attempt++;
    }

    console.error('Failed to fetch care settings data after', retries, 'attempts');
    return null;
  } catch (err) {
    console.error('Error in getCareSettingsData:', err);
    return null;
  }
}

// Function to get encounter statistics
export async function getEncounterStatistics() {
  try {
    const { data, error } = await supabase
      .from('encounter_statistics')
      .select('*')
      .order('care_setting', { ascending: true });

    if (error) {
      console.error('Error fetching encounter statistics:', error);
      return null;
    }

    return data;
  } catch (err) {
    console.error('Error in getEncounterStatistics:', err);
    return null;
  }
}

// Function to get top ICD codes by encounters
export async function getTopICDCodes(limit = 10) {
  try {
    const { data, error } = await supabase
      .from('top_icd_codes_by_encounters')
      .select('*')
      .limit(limit);

    if (error) {
      console.error('Error fetching top ICD codes:', error);
      return null;
    }

    return data;
  } catch (err) {
    console.error('Error in getTopICDCodes:', err);
    return null;
  }
}