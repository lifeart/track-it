import type { Task } from '@/types/app';
import { parseISO, startOfMonth, isAfter } from 'date-fns';

export const formatDate = (date: string) => {
  const currentLocale = navigator.language;
  return new Date(date).toLocaleDateString(currentLocale, {
    dateStyle: 'short',
  });
};

export const formatDuration = (raw: number) => {
  const milliseconds = Math.abs(raw);
  const hours = Math.floor(milliseconds / 3600000);
  const minutes = Math.floor((milliseconds % 3600000) / 60000);
  const prefix = raw < 0 ? '-' : '';
  if (hours === 0) {
    return `${prefix}${minutes}m`;
  } else if (minutes === 0) {
    return `${prefix}${hours}h`;
  }
  return `${prefix}${hours}h ${minutes}m`;
};

export const totalTime = (task: Task) => {
  return task.durations.reduce((sum, duration) => sum + duration.time, 0);
};

export const monthlyTime = (task: Task) => {
  const startOfCurrentMonth = startOfMonth(new Date());

  return task.durations
    .filter((duration) => isAfter(parseISO(duration.date), startOfCurrentMonth))
    .reduce((sum, duration) => sum + duration.time, 0);
};
