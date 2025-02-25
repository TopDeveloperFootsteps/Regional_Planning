import React, { useState } from 'react';
import { Clock } from 'lucide-react';

interface VisitTimeData {
  levelOfCare: string;
  reasonForVisit: string;
  newVisitDuration: number;
  followUpVisitDuration: number;
  percentNewVisits: number;
  source: string;
}

interface EditableNumberCellProps {
  value: number;
  onChange: (value: number) => void;
}

interface EditableTextCellProps {
  value: string;
  onChange: (value: string) => void;
}

const EditableNumberCell: React.FC<EditableNumberCellProps> = ({ value, onChange }) => (
  <input
    type="number"
    value={value}
    onChange={(e) => onChange(Number(e.target.value))}
    className="w-20 px-2 py-1 text-sm border rounded focus:outline-none focus:ring-1 focus:ring-emerald-500"
  />
);

const EditableTextCell: React.FC<EditableTextCellProps> = ({ value, onChange }) => (
  <input
    type="text"
    value={value}
    onChange={(e) => onChange(e.target.value)}
    className="w-full px-2 py-1 text-sm border rounded focus:outline-none focus:ring-1 focus:ring-emerald-500"
  />
);

export function SpecialistVisitTimeAssumptions() {
  const [visitTimes, setVisitTimes] = useState<VisitTimeData[]>([
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'General Surgery', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 45, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Urology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 31, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Vascular Surgery', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 47, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Otolaryngology / ENT', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 43, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Ophthalmology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 26, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Dentistry', newVisitDuration: 60, followUpVisitDuration: 60, percentNewVisits: 8, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Plastics (incl. Burns and Maxillofacial)', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 33, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Paediatric Surgery', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 38, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Trauma and Emergency Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 73, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Anesthesiology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 36, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Critical Care Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 38, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Gastroenterology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 34, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Endocrinology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 21, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Haematology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 10, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Medical Genetics', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 61, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Neurosurgery', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 32, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Cardiothoracic & Cardiovascular Surgery', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 28, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Internal Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 58, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Allergy and Immunology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 42, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Physical Medicine and Rehabilitation', newVisitDuration: 60, followUpVisitDuration: 60, percentNewVisits: 35, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Hospice and Palliative Care', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 19, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Cardiology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 42, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Paediatric Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 37, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Dermatology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 57, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Pulmonology / Respiratory Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 31, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Infectious Diseases', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 48, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 14, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Nephrology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 10, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Oncology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 11, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Nuclear Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 52, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Neurology (inc. neurophysiology and neuropathology)', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 33, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Rheumatology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 17, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Elderly Care / Geriatrics', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 49, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Obstetrics & Gynaecology', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 35, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Psychiatry', newVisitDuration: 60, followUpVisitDuration: 60, percentNewVisits: 17, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Social, Community and Preventative Medicine', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 39, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Other', newVisitDuration: 25, followUpVisitDuration: 25, percentNewVisits: 31, source: 'BMJ' },
    { levelOfCare: 'Specialist Outpatient Care', reasonForVisit: 'Orthopaedics (inc. podiatry)', newVisitDuration: 30, followUpVisitDuration: 20, percentNewVisits: 36, source: 'BMJ' }
  ]);

  const updateVisitTime = (index: number, field: keyof VisitTimeData, value: number | string) => {
    const newData = [...visitTimes];
    newData[index] = { ...newData[index], [field]: value };
    setVisitTimes(newData);
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Clock className="h-6 w-6 text-emerald-600" />
        <h2 className="text-xl font-semibold text-gray-900">Average Visit Time for Specialist Outpatient Care</h2>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Level of Care</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason for Visit</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">New Visit Duration (minutes)</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Follow-Up Visit Duration (minutes)</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">% New Visits</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Source</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {visitTimes.map((row, index) => (
              <tr key={index} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{row.levelOfCare}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{row.reasonForVisit}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.newVisitDuration} 
                    onChange={(value) => updateVisitTime(index, 'newVisitDuration', value)} 
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.followUpVisitDuration} 
                    onChange={(value) => updateVisitTime(index, 'followUpVisitDuration', value)} 
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.percentNewVisits} 
                    onChange={(value) => updateVisitTime(index, 'percentNewVisits', value)} 
                  />
                </td>
                <td className="px-6 py-4">
                  <EditableTextCell 
                    value={row.source} 
                    onChange={(value) => updateVisitTime(index, 'source', value)} 
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}