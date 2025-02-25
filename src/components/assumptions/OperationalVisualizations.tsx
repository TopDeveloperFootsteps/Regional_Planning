import React from 'react';
import { Calendar, Clock, Building2, Bed, Stethoscope, Activity, Scan, CalendarDays } from 'lucide-react';

interface WorkingDaysData {
  setting: string;
  daysPerWeek: number;
  weeksPerYear: number;
  daysPerYear: number;
}

interface WorkingHoursData {
  setting: string;
  hoursPerDay: number;
}

interface OccupancyRateData {
  setting: string;
  inPersonRate: number;
  virtualRate: number | null;
}

interface OperationalVisualizationsProps {
  workingDays: WorkingDaysData[];
  workingHours: WorkingHoursData[];
  occupancyRates: OccupancyRateData[];
}

const getSettingIcon = (setting: string) => {
  switch (setting) {
    case 'Primary Care':
      return <Building2 className="h-8 w-8 text-emerald-600" />;
    case 'Specialist Outpatient Care':
      return <Stethoscope className="h-8 w-8 text-emerald-600" />;
    case 'Emergency Care':
      return <Activity className="h-8 w-8 text-red-600" />;
    case 'Major Diagnostic & Treatment':
      return <Scan className="h-8 w-8 text-blue-600" />;
    case 'Day Cases':
      return <CalendarDays className="h-8 w-8 text-emerald-600" />;
    case 'Inpatient Care':
      return <Bed className="h-8 w-8 text-blue-600" />;
    default:
      return <Building2 className="h-8 w-8 text-emerald-600" />;
  }
};

const WeekDayIndicator = ({ daysPerWeek }: { daysPerWeek: number }) => {
  return (
    <div className="flex space-x-1">
      {Array.from({ length: 7 }).map((_, i) => (
        <div
          key={i}
          className={`h-1 w-4 rounded-full ${
            i < daysPerWeek ? 'bg-emerald-500' : 'bg-gray-200'
          }`}
        />
      ))}
    </div>
  );
};

const HourIndicator = ({ hoursPerDay }: { hoursPerDay: number }) => {
  return (
    <div className="flex items-center space-x-2">
      <Clock className="h-4 w-4 text-emerald-600" />
      <span className="text-sm font-medium text-gray-700">{hoursPerDay} hours/day</span>
    </div>
  );
};

export function OperationalVisualizations({ workingDays, workingHours, occupancyRates }: OperationalVisualizationsProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {workingDays.map((setting, index) => {
        const hours = workingHours.find(h => h.setting === setting.setting);
        const occupancy = occupancyRates.find(o => o.setting === setting.setting);

        return (
          <div key={index} className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center space-x-4 mb-4">
              {getSettingIcon(setting.setting)}
              <div>
                <h3 className="text-lg font-semibold text-gray-900">{setting.setting}</h3>
              </div>
            </div>

            <div className="space-y-4">
              {/* Working Days Indicator */}
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Working Days</span>
                  <span className="text-sm font-medium text-gray-700">
                    {setting.daysPerWeek} days/week
                  </span>
                </div>
                <WeekDayIndicator daysPerWeek={setting.daysPerWeek} />
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4 text-emerald-600" />
                  <span className="text-sm text-gray-600">{setting.weeksPerYear} weeks/year</span>
                </div>
              </div>

              {/* Working Hours */}
              {hours && (
                <div className="pt-2 border-t border-gray-100">
                  <HourIndicator hoursPerDay={hours.hoursPerDay} />
                </div>
              )}

              {/* Occupancy Rate */}
              {occupancy && (
                <div className="pt-2 border-t border-gray-100">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-600">Occupancy Rate</span>
                    <span className="text-sm font-medium text-gray-700">
                      {occupancy.inPersonRate}%
                    </span>
                  </div>
                  <div className="mt-2 bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${occupancy.inPersonRate}%` }}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}