const storageKey = `trackit`;

type StorageKey = 'tasks';

type ReadTypes = string | object | undefined;
export function read<T extends ReadTypes>(key: StorageKey, defaultValue: T): T {
  const accessKey = `${storageKey}/${key}`;
  try {
    if (typeof defaultValue === 'object') {
      const value = localStorage.getItem(accessKey);
      return value ? JSON.parse(value) : defaultValue;
    } else {
      return (localStorage.getItem(accessKey) as T) ?? defaultValue;
    }
  } catch {
    return defaultValue;
  }
}
export function write(key: StorageKey, rawValue: string | object) {
  const value =
    typeof rawValue === 'string' ? rawValue : JSON.stringify(rawValue);
  const accessKey = `${storageKey}/${key}`;
  try {
    localStorage.setItem(accessKey, value);
  } catch (e) {
    // OOPS
  }
}
export function remove(key: StorageKey) {
  const accessKey = `${storageKey}/${key}`;
  try {
    localStorage.removeItem(accessKey);
  } catch (e) {
    // OOPS
  }
  return;
}
