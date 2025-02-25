import React from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { SpecialistOPDCapacityCalculation } from './SpecialistOPDCapacityCalculation';
import { PrimaryOPDCapacityCalculation } from './PrimaryOPDCapacityCalculation';

export function OPDCapacityCalculation() {
  return (
    <div className="space-y-8">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <Tabs defaultValue="primary" className="w-full">
          <TabsList className="mb-6">
            <TabsTrigger value="primary">Primary Care</TabsTrigger>
            <TabsTrigger value="specialist">Specialist OPD</TabsTrigger>
          </TabsList>
          <TabsContent value="primary">
            <PrimaryOPDCapacityCalculation />
          </TabsContent>
          <TabsContent value="specialist">
            <SpecialistOPDCapacityCalculation />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}