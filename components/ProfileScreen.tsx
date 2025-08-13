import React from 'react';
import Header from './Header';
import ProficiencySelector from './ProficiencySelector';
import { ProficiencyLevel, Recording } from '../types';

interface ProfileScreenProps {
  proficiency: ProficiencyLevel;
  setProficiency: (level: ProficiencyLevel) => void;
  onBack: () => void;
  recordings: Recording[];
  setRecordings: (recordings: Recording[]) => void;
}

const ProfileScreen: React.FC<ProfileScreenProps> = ({ proficiency, setProficiency, onBack, recordings, setRecordings }) => {

  const totalSessions = recordings.length;
  const totalXp = recordings.reduce((acc, rec) => {
      const base = Math.round(rec.feedback.overallScore);
      const bonus = rec.feedback.challengeWordsUsed.filter(w => w.used).length * 5;
      return acc + base + bonus;
  }, 0);

  const handleClearHistory = () => {
    if (window.confirm("Are you sure you want to delete all your practice history? This action cannot be undone.")) {
        setRecordings([]);
    }
  }

  return (
    <div className="flex flex-col h-full bg-lingo-bg">
      <Header title="My Profile" onBack={onBack} />
      <div className="flex-grow flex flex-col p-6 overflow-y-auto">
        <div className="mb-8">
            <h2 className="text-sm font-bold text-lingo-text-secondary uppercase tracking-wider mb-2">My Level</h2>
            <ProficiencySelector selectedLevel={proficiency} onLevelChange={setProficiency} />
            <p className="text-xs text-lingo-text-secondary mt-2">Setting your level helps Lingo give you better feedback and more relevant challenge words.</p>
        </div>

        <div className="mb-8">
            <h2 className="text-sm font-bold text-lingo-text-secondary uppercase tracking-wider mb-2">Statistics</h2>
            <div className="grid grid-cols-2 gap-4">
                <div className="bg-white p-4 rounded-xl border border-border-gray text-center">
                    <p className="text-3xl font-bold text-lingo-blue">{totalSessions}</p>
                    <p className="text-sm text-lingo-text-secondary">Sessions</p>
                </div>
                 <div className="bg-white p-4 rounded-xl border border-border-gray text-center">
                    <p className="text-3xl font-bold text-accent-xp">{totalXp}</p>
                    <p className="text-sm text-lingo-text-secondary">Total XP</p>
                </div>
            </div>
        </div>

        <div className="flex-grow"></div>

        <div>
             <h2 className="text-sm font-bold text-lingo-text-secondary uppercase tracking-wider mb-2">Account</h2>
            <button
                onClick={handleClearHistory}
                className="w-full text-center py-3 px-4 text-lingo-red bg-lingo-red/10 rounded-xl hover:bg-lingo-red/20 transition-colors font-semibold"
            >
                Clear Practice History
            </button>
        </div>

      </div>
    </div>
  );
};

export default ProfileScreen;