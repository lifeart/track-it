import { BaseTask, Task, TaskDuration } from '@/types/app';

const storageKey = `trackit`;
export const MAX_ALLOWED_CHARACTERS = 4096;


export function toKey(key: string) {
  return `${storageKey}__${key}`;
}
export function asKey(key: string) {
  return key.replace(`${storageKey}__`, '');
}
export function toBaseTask(task: Task): BaseTask {
  return {
    uuid: task.uuid,
    label: task.label,
    description: task.description,
  };
}

export function keyFromDateString(uuid: string, dateString: string) {
  const ddate = new Date(dateString);
  const durationsKey = `${uuid}_${ddate.getFullYear()}_${ddate.getMonth()}`;
  return durationsKey;
}

export function splitTaskDurationsByMonths(
  taskId: string,
  durations: TaskDuration[],
) {
  const durationsMap: Record<string, TaskDuration[]> = {};
  durations.forEach((d) => {
    const key = keyFromDateString(taskId, d.date);
    if (!(key in durationsMap)) {
      durationsMap[key] = [];
    }
    durationsMap[key].push(d);
  });
  return durationsMap;
}
