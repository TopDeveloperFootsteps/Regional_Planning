import React, { useState, useEffect } from "react";
import { api } from "../../services/api";
import { Calculator, Clock, Calendar, Save } from "lucide-react";

interface AvailableDays {
  care_setting: string;
  working_days_per_week: number;
  working_weeks_per_year: number;
  available_days_per_year: number;
}

interface WorkingHours {
  care_setting: string;
  working_hours_per_day: number;
}

interface VisitTime {
  reason_for_visit: string;
  new_visit_duration: number;
  follow_up_visit_duration: number;
  percent_new_visits: number;
  average_visit_duration: number;
}

interface SlotCalculation {
  service: string;
  totalMinutesPerYear: number;
  totalSlotsPerYear: number;
  averageVisitDuration: number;
  newVisitsPerYear: number;
  followUpVisitsPerYear: number;
  slotsPerDay: number;
}

export function PrimaryOPDCapacityCalculation() {
  const [availableDays, setAvailableDays] = useState<AvailableDays | null>(
    null
  );
  const [workingHours, setWorkingHours] = useState<WorkingHours | null>(null);
  const [visitTimes, setVisitTimes] = useState<VisitTime[]>([]);
  const [slotCalculations, setSlotCalculations] = useState<SlotCalculation[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [selectedYear, setSelectedYear] = useState(2025);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  const calculateAndSaveSlots = async (
    days: AvailableDays,
    hours: WorkingHours,
    times: VisitTime[]
  ) => {
    const calculations = times.map((service) => {
      const totalMinutesPerYear =
        days.available_days_per_year * hours.working_hours_per_day * 60;

      const averageVisitDuration =
        (service.new_visit_duration * service.percent_new_visits +
          service.follow_up_visit_duration *
            (100 - service.percent_new_visits)) /
        100;

      const totalSlotsPerYear = Math.floor(
        totalMinutesPerYear / averageVisitDuration
      );
      const newVisitsPerYear = Math.floor(
        totalSlotsPerYear * (service.percent_new_visits / 100)
      );
      const followUpVisitsPerYear = totalSlotsPerYear - newVisitsPerYear;
      const slotsPerDay = Math.floor(
        totalSlotsPerYear / days.available_days_per_year
      );

      return {
        service: service.reason_for_visit,
        totalMinutesPerYear,
        totalSlotsPerYear,
        averageVisitDuration,
        newVisitsPerYear,
        followUpVisitsPerYear,
        slotsPerDay,
      };
    });

    setSlotCalculations(calculations);

    // Save calculations to database
    try {
      setSaving(true);
      setSaveError(null);

      // const { error } = await api.post(
      //   "/opdCapacity/save_capacity_calculations",
      //   calculations
      // );
      // if (error) throw error;
    } catch (error) {
      console.error("Error saving capacity calculations:", error);
      setSaveError("Failed to save calculations");
    } finally {
      setSaving(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);

      const [daysData, hoursData, timesData] = await Promise.all([
        api.get("/opdCapacity/available_days"),
        api.get("/opdCapacity/working_hours"),
        api.get("/opdCapacity/visit_times"),
      ]);

      if (daysData && hoursData && timesData) {
        setAvailableDays(daysData);
        setWorkingHours(hoursData);
        setVisitTimes(timesData);
        await calculateAndSaveSlots(daysData, hoursData, timesData);
      }
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  const totalMinutesPerYear =
    availableDays && workingHours
      ? availableDays.available_days_per_year *
        workingHours.working_hours_per_day *
        60
      : 0;

  return (
    <div className="space-y-8">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Calendar className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">
                Available Days
              </p>
              <h3 className="text-2xl font-bold text-gray-900">
                {availableDays?.available_days_per_year || 0}
              </h3>
              <p className="text-xs text-gray-500">
                {availableDays?.working_days_per_week || 0} days/week ×{" "}
                {availableDays?.working_weeks_per_year || 0} weeks
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Clock className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">Working Hours</p>
              <h3 className="text-2xl font-bold text-gray-900">
                {workingHours?.working_hours_per_day || 0}
              </h3>
              <p className="text-xs text-gray-500">hours per day</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Clock className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">
                Total Minutes/Year
              </p>
              <h3 className="text-2xl font-bold text-gray-900">
                {totalMinutesPerYear.toLocaleString()}
              </h3>
              <p className="text-xs text-gray-500">available minutes</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Calculator className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">
                Total Services
              </p>
              <h3 className="text-2xl font-bold text-gray-900">
                {visitTimes.length}
              </h3>
              <p className="text-xs text-gray-500">unique specialties</p>
            </div>
          </div>
        </div>
      </div>

      {/* Add save status */}
      {(saving || saveError) && (
        <div
          className={`flex items-center justify-center p-2 rounded ${
            saveError
              ? "bg-red-50 text-red-600"
              : "bg-emerald-50 text-emerald-600"
          }`}
        >
          {saving ? (
            <>
              <Save className="h-4 w-4 animate-spin mr-2" />
              <span>Saving calculations...</span>
            </>
          ) : saveError ? (
            <span>{saveError}</span>
          ) : null}
        </div>
      )}

      {/* Slot Calculations Table */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-6">
          Primary Care Slot Calculations
        </h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Service
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Minutes/Year
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Avg. Visit Duration
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Slots/Year
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  New Visits/Year
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Follow-up Visits/Year
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Slots/Day
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {slotCalculations.map((calc, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {calc.service}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.totalMinutesPerYear.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.averageVisitDuration.toFixed(1)} min
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.totalSlotsPerYear.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.newVisitsPerYear.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.followUpVisitsPerYear.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {calc.slotsPerDay.toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
