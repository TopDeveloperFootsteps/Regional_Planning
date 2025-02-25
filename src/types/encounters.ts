export interface EncounterStats {
  care_setting: string;
  record_count: number;
  encounter_count: number;
  system_distribution?: Record<string, number>;
  icd_code_count?: number;
  top_icd_codes?: Array<{
    icd_family_code: string;
    description: string;
    encounters: number;
    percentage: number;
  }>;
}

export interface SystemOfCareStats {
  system_of_care: string;
  total_encounters: number;
  care_setting_percentages: Record<string, number>;
}

export interface OptimizationData {
  care_setting: string;
  current_encounters: number;
  current_percentage: number;
  shift_potential: number;
  shift_direction: string;
  potential_shift_percentage: number;
  proposed_percentage: number;
  potential_encounters_change: number;
  optimization_strategy: string;
}