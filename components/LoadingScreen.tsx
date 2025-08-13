import React from 'react';

const LoadingSpinner: React.FC = () => (
    <div className="w-16 h-16 border-4 border-lingo-blue border-t-transparent rounded-full animate-spin"></div>
);

const LoadingScreen: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center h-full bg-lingo-bg">
      <LoadingSpinner />
      <p className="text-lg font-semibold text-lingo-text-secondary mt-8 animate-pulse">
        Lingo is analyzing your speech...
      </p>
    </div>
  );
};

export default LoadingScreen;