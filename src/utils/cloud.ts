import { type BaseTask, type Task, type TaskDuration } from '@/types/app';
import {
  keyFromDateString,
  splitTaskDurationsByMonths,
  toBaseTask,
} from './utils';
import {
  getCloudStorageDataByKeys,
  getCloudStorageKeys,
  loadFromCloudStorage,
  removeKeysFromCloudStorage,
  saveToCloudStorage,
} from './cloud-storage';

export async function addTaskDurationToAsyncStorage(
  uuid: string,
  duration: TaskDuration,
) {
  const durationsKey = keyFromDateString(uuid, duration.date);
  let bucket: TaskDuration[] = [];
  try {
    const rawBucket = await loadFromCloudStorage(durationsKey);
    if (Array.isArray(rawBucket)) {
      bucket = rawBucket;
    } else {
      console.info(`Invalid data for key ${durationsKey}`);
    }
  } catch (e) {
    // EOL
  }
  bucket.push(duration);
  await saveToCloudStorage(durationsKey, bucket);
}
export async function removeTaskFromAsyncStorage(uuid: string) {
  await addRemovedTaskIdToAsyncStorage(uuid);
  const tasks = (await loadFromCloudStorage('tasks')) as BaseTask[] | null;
  if (!tasks) {
    return;
  }
  const clearedTasks = tasks.filter((t) => t.uuid !== uuid);
  await saveToCloudStorage('tasks', clearedTasks);
  const keys = await getCloudStorageKeys();
  const removedTaskKeys = keys.filter((key) => key.startsWith(`${uuid}_`));
  await removeKeysFromCloudStorage(removedTaskKeys);
}
export async function loadTasksFromAsyncStorage() {
  let tasks = (await loadFromCloudStorage('tasks')) as BaseTask[] | null;
  const resolvedTasks: Task[] = [];
  if (tasks === null || !Array.isArray(tasks)) {
    return resolvedTasks;
  }
  const uuids = tasks.map((t) => t.uuid);
  const keys = await getCloudStorageKeys();
  const knownKeys = keys.filter((k) => {
    return uuids.find((u) => k.startsWith(`${u}_`));
  });
  const unknownKeys = keys.filter((k) => {
    return !uuids.find((u) => k.startsWith(`${u}_`));
  });
  await removeKeysFromCloudStorage(unknownKeys);
  const keysForTasks: Record<string, string[]> = {};
  knownKeys.forEach((key) => {
    const [uuid, _year, _month] = key.split('_') as [string, string, string];
    if (!(uuid in keysForTasks)) {
      keysForTasks[uuid] = [];
    }
    keysForTasks[uuid].push(key);
  });
  const rawData = await getCloudStorageDataByKeys(knownKeys);
  const properTasks: Task[] = tasks.map((t) => {
    return { ...t, durations: [] };
  });
  Object.keys(keysForTasks).forEach((uuid) => {
    const t = properTasks.find((task) => task.uuid === uuid);
    if (!t) {
      return;
    }
    const relatedKeys = keysForTasks[uuid];
    relatedKeys.forEach((key) => {
      if (key in rawData) {
        try {
          const durationData = JSON.parse(rawData[key]) as TaskDuration[];
          if (Array.isArray(durationData)) {
            t.durations.push(...durationData);
          }
        } catch (e) {
          removeKeysFromCloudStorage([key]);
        }
      }
    });
  });
  return properTasks;
}
export async function saveTaskDurationsToAsyncStorage(task: Task) {
  const results = splitTaskDurationsByMonths(task.uuid, task.durations);
  const keys = Object.keys(results);
  for (let key of keys) {
    await saveToCloudStorage(key, results[key]);
  }
}
export async function saveTasksListToAsyncStorage(tasks: Task[]) {
  const baseTasks = tasks.map((t) => toBaseTask(t));
  await saveToCloudStorage('tasks', baseTasks);
}
export async function saveTasksToAsyncStorage(tasks: Task[]) {
  await saveTasksListToAsyncStorage(tasks);
  for (const t of tasks) {
    await saveTaskDurationsToAsyncStorage(t);
  }
}
export async function addTaskToAsyncStorage(task: Task) {
  const tasks = (await loadFromCloudStorage('tasks')) as BaseTask[] | null;
  if (!tasks) {
    return;
  }
  tasks.push(toBaseTask(task));
  await saveToCloudStorage('tasks', tasks);
  await saveTaskDurationsToAsyncStorage(task);
}
export async function getRemovedTaskIdsFromAsyncStorage() {
  const result = (await loadFromCloudStorage('removed_tasks')) as
    | string[]
    | null;
  if (!Array.isArray(result)) {
    return [];
  } else {
    return result;
  }
}
export async function addRemovedTaskIdToAsyncStorage(id: string) {
  const results = await getRemovedTaskIdsFromAsyncStorage();
  if (results.includes(id)) {
    return;
  }
  results.push(id);
  await saveToCloudStorage('removed_tasks', results);
}
