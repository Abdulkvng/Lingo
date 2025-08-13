import React from 'react';
import Header from './Header';
import LanguageSelector from './LanguageSelector';
import { Screen, ProficiencyLevel } from '../types';

interface PromptScreenProps {
  prompt: string;
  onStartRecording: () => void;
  onNavigate: (screen: Screen) => void;
  error: string | null;
  targetLanguage: string;
  onLanguageChange: (lang: string) => void;
  challengeWords: string[];
  isLoadingWords: boolean;
  proficiencyLevel: ProficiencyLevel;
}

const PromptScreen: React.FC<PromptScreenProps> = ({ 
  prompt, 
  onStartRecording, 
  onNavigate, 
  error,
  targetLanguage,
  onLanguageChange,
  challengeWords,
  isLoadingWords,
  proficiencyLevel
}) => {
  return (
    <div className="flex flex-col h-full bg-lingo-bg">
      <Header title="Lingo" showProfileIcon onProfileClick={() => onNavigate(Screen.Profile)} />
      <div className="flex-grow flex flex-col justify-between p-6 overflow-y-auto">
        <div>
          <div className="flex justify-between items-start">
            <LanguageSelector selectedLanguage={targetLanguage} onLanguageChange={onLanguageChange} />
            <div className="text-right">
                <p className="block text-sm font-bold text-lingo-text-secondary uppercase tracking-wider">Level</p>
                <p className="mt-1 font-semibold text-lingo-blue">{proficiencyLevel}</p>
            </div>
          </div>
          
          <div className="mt-6">
              <p className="text-sm text-lingo-text-secondary font-bold uppercase tracking-wider">Today's Topic</p>
              <p className="text-2xl text-lingo-text mt-2 font-serif">{prompt}</p>
          </div>

          <div className="mt-6">
              <p className="text-sm text-accent-challenge font-bold uppercase tracking-wider">Challenge Words</p>
              <div className="mt-2 p-4 bg-white rounded-xl border border-border-gray min-h-[6rem]">
                {isLoadingWords ? (
                  <div className="flex items-center justify-center h-full">
                    <div className="w-5 h-5 border-2 border-lingo-blue border-t-transparent rounded-full animate-spin"></div>
                    <p className="ml-3 text-lingo-text-secondary">Generating words...</p>
                  </div>
                ) : (
                   challengeWords.length > 0 ? (
                      <ul className="flex flex-wrap gap-2">
                        {challengeWords.map(word => (
                          <li key={word} className="bg-accent-challenge/10 text-accent-challenge font-semibold px-3 py-1 rounded-full text-sm">
                            {word}
                          </li>
                        ))}
                      </ul>
                   ) : (
                     <p className="text-lingo-text-secondary text-center">Could not load words. You can still practice.</p>
                   )
                )}
              </div>
          </div>
        </div>
        
        {error && <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-xl relative mt-4" role="alert">
          <strong className="font-bold">Error: </strong>
          <span className="block sm:inline">{error}</span>
        </div>}

        <div className="w-full pt-4 mt-4">
          <button
            onClick={onStartRecording}
            disabled={isLoadingWords}
            className="w-full bg-lingo-blue text-white font-bold py-4 px-4 rounded-xl hover:bg-lingo-blue-dark transition-colors text-lg disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            Start Recording
          </button>
          <button
            onClick={() => onNavigate(Screen.Dashboard)}
            className="w-full mt-4 text-lingo-blue font-bold py-4 px-4 rounded-xl border-2 border-border-gray hover:bg-gray-100 transition-colors text-lg"
          >
            View Progress
          </button>
        </div>
      </div>
    </div>
  );
};

export default PromptScreen;