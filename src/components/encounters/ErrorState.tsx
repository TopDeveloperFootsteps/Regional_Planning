import React from 'react';
import { WifiOff, RefreshCw } from 'lucide-react';
import { Header } from '../Header';
import { Footer } from '../Footer';

interface ErrorStateProps {
  error: string;
  onRetry?: () => void;
  retrying?: boolean;
}

export function ErrorState({ error, onRetry, retrying }: ErrorStateProps) {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-6">
            <div className="flex items-center space-x-2 mb-4">
              <WifiOff className="h-5 w-5 text-red-500" />
              <p className="text-red-600">{error}</p>
            </div>
            {onRetry && (
              <button
                onClick={onRetry}
                disabled={retrying}
                className="flex items-center space-x-2 px-4 py-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-md transition-colors disabled:opacity-50"
              >
                <RefreshCw className={`h-4 w-4 ${retrying ? 'animate-spin' : ''}`} />
                <span>{retrying ? 'Retrying...' : 'Retry Connection'}</span>
              </button>
            )}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}