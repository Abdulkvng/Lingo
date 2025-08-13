import React from 'react';

interface LanguageSelectorProps {
  selectedLanguage: string;
  onLanguageChange: (language: string) => void;
}

const LANGUAGES = ["English", "Spanish", "French", "German", "Italian", "Japanese", "Yoruba"];

const LanguageSelector: React.FC<LanguageSelectorProps> = ({ selectedLanguage, onLanguageChange }) => {
  return (
    <div>
      <label htmlFor="language-select" className="block text-sm font-bold text-lingo-text-secondary uppercase tracking-wider">
        I'm practicing
      </label>
      <select
        id="language-select"
        value={selectedLanguage}
        onChange={(e) => onLanguageChange(e.target.value)}
        className="mt-1 block w-full pl-3 pr-10 py-2 text-base border-border-gray focus:outline-none focus:ring-lingo-blue focus:border-lingo-blue sm:text-sm rounded-md font-semibold"
      >
        {LANGUAGES.map((lang) => (
          <option key={lang} value={lang}>
            {lang}
          </option>
        ))}
      </select>
    </div>
  );
};

export default LanguageSelector;