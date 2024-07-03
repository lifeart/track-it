import { asKey, MAX_ALLOWED_CHARACTERS, toKey } from './utils';
const RESERVED_KEYS = ['tasks', 'removed_tasks'];

export async function getCloudStorageDataByKeys(
  keys: string[],
): Promise<Record<string, string>> {
  return new Promise((resolve, reject) => {
    try {
      Telegram.WebApp.CloudStorage.getItems(keys, (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result);
        }
      });
    } catch (e) {
      reject(e);
    }
  });
}

function toValue(value: any) {
  const result = JSON.stringify(value);
  if (result.length >= MAX_ALLOWED_CHARACTERS) {
    throw new Error('Results out of character limit');
  }
  return result;
}

export async function saveToCloudStorage(key: string, value: any) {
  return new Promise((resolve, reject) => {
    try {
      Telegram.WebApp.CloudStorage.setItem(
        toKey(key),
        toValue(value),
        (err, result) => {
          if (err) {
            reject(err);
          } else {
            resolve(result);
          }
        },
      );
    } catch (e) {
      // EOL
      reject(e);
    }
  });
}

export async function getCloudStorageKeys(): Promise<string[]> {
  return new Promise((resolve, reject) => {
    try {
      Telegram.WebApp.CloudStorage.getKeys((err, keys) => {
        if (err) {
          reject(err);
        } else {
          resolve(
            keys.map((k) => {
              return asKey(k);
            }).filter((k) => !RESERVED_KEYS.includes(k)),
          );
        }
      });
    } catch (e) {
      reject(e);
    }
  });
}

export async function removeKeysFromCloudStorage(rawKeys: string[]) {
  if (!rawKeys.length) {
    return;
  }
  const keys = rawKeys.map((k) => {
    return toKey(k);
  });
  return new Promise((resolve, reject) => {
    try {
      Telegram.WebApp.CloudStorage.removeItems(keys, (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result);
        }
      });
    } catch (e) {
      reject(e);
    }
  });
}

export async function loadFromCloudStorage(key: string) {
  return new Promise((resolve, reject) => {
    try {
      Telegram.WebApp.CloudStorage.getItem(toKey(key), (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result ? JSON.parse(result) : null);
        }
      });
    } catch (e) {
      // EOL
      reject(e);
    }
  });
}
