import React from 'react';
import { Chart as ChartJS, RadialLinearScale, PointElement, LineElement, Filler, Tooltip } from 'chart.js';
import { Radar } from 'react-chartjs-2';
import { AIFeedback } from '../types';

ChartJS.register(RadialLinearScale, PointElement, LineElement, Filler, Tooltip);

interface RadarChartProps {
  feedback: AIFeedback;
}

const RadarChart: React.FC<RadarChartProps> = ({ feedback }) => {
  const data = {
    labels: ['Grammar', 'Pronunciation', 'Fluency', 'Vocabulary', 'Clarity'],
    datasets: [
      {
        label: 'Score',
        data: [
          feedback.grammar.score,
          feedback.pronunciation.score,
          feedback.fluency.score,
          feedback.vocabulary.score,
          feedback.clarity.score,
        ],
        backgroundColor: 'rgba(0, 122, 255, 0.2)',
        borderColor: 'rgba(0, 122, 255, 1)',
        borderWidth: 2,
        pointBackgroundColor: 'rgba(0, 122, 255, 1)',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: 'rgba(0, 122, 255, 1)',
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      tooltip: {
        callbacks: {
          label: (context: any) => `${context.dataset.label}: ${context.raw}%`
        }
      },
      legend: {
        display: false
      }
    },
    scales: {
      r: {
        angleLines: {
          color: '#E5E7EB',
        },
        grid: {
          color: '#E5E7EB',
        },
        pointLabels: {
          font: {
            size: 12,
            weight: 'bold',
          },
          color: '#1A1A1A'
        },
        ticks: {
          display: false,
          stepSize: 20
        },
        suggestedMin: 0,
        suggestedMax: 100,
      },
    },
  };

  return <Radar data={data} options={options} />;
};

export default RadarChart;