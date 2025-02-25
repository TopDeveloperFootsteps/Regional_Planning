import React from 'react';
import { RefreshCw } from 'lucide-react';
import { Header } from '../Header';
import { Footer } from '../Footer';

export function LoadingState() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-center h-64">
            <div className="flex items-center space-x-2 text-emerald-600">
              <RefreshCw className="h-5 w-5 animate-spin" />
              <span>Loading statistics...</span>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}