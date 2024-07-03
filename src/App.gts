import { Component, cellFor, tracked } from '@lifeart/gxt';

import { AddDuration } from './components/AddDuration';
import { AddTask } from './components/AddTask';
import type { Task, TaskDuration } from './types/app';
import { TaskList } from './components/TaskList';
import { read, write } from './utils/persisted';
import { TaskDetails } from './components/TaskDetails';
import { uuid } from './utils/id';
import {
  addTaskDurationToAsyncStorage,
  addTaskToAsyncStorage,
  loadTasksFromAsyncStorage,
  removeTaskFromAsyncStorage,
  saveTasksToAsyncStorage,
  getRemovedTaskIdsFromAsyncStorage,
} from './utils/cloud';

export default class App extends Component {
  @tracked tasks: Task[] = read('tasks', []).map((task: Task) => {
    if (!task.uuid) {
      task.uuid = uuid();
    }
    cellFor(task, 'durations');
    return task;
  });
  @tracked selectedTask: Task | null = null;
  selectTask = (task: Task | null) => {
    if (this.selectedTask === task) {
      this.selectedTask = null;
      return;
    }
    this.selectedTask = task;
    this.taskDetailsToggled = false;
    try {
      Telegram.WebApp.HapticFeedback.selectionChanged();
    } catch (e) {
      // FINE
    }
  };
  editTask = (task: Task) => {
    this.tasks = this.tasks.map((t) => {
      if (t.uuid === task.uuid) {
        return task;
      } else {
        return t;
      }
    });
    console.log('edit', task);
  };
  confirm(prompt: string) {
    if (this.inTelegram) {
      try {
        Telegram.WebApp.HapticFeedback.impactOccurred('light');
      } catch (e) {
        // FINE
      }
      return new Promise((resolve) => {
        Telegram.WebApp.showConfirm(prompt, resolve);
      });
    }
    return confirm(prompt);
  }
  onRemoveTask = (task: Task) => {
    this.removeTask(task);
  };
  removeTask = async (task: Task, skipCloudSync = false) => {
    if (!skipCloudSync) {
      if (!(await this.confirm('Are you sure you want to remove this task?'))) {
        return;
      }
    }
    this.tasks = this.tasks.filter((t) => t.uuid !== task.uuid);
    if (this.selectedTask === task) {
      this.selectedTask = null;
    }
    write('tasks', this.tasks);
    if (skipCloudSync) {
      return;
    }
    removeTaskFromAsyncStorage(task.uuid).catch(() => {
      console.info(`Unable to remove task from async storage`);
    });
    try {
      Telegram.WebApp.HapticFeedback.notificationOccurred('success');
    } catch (e) {
      // FINE
    }
  };
  addTask = (task: Task) => {
    const taksWithSameLebel = this.tasks.find((t) => t.label === task.label);
    if (taksWithSameLebel) {
      try {
        Telegram.WebApp.HapticFeedback.notificationOccurred('error');
      } catch (e) {
        // FINE
      }
      alert(`Task with label ${task.label} already exists`);
      return;
    }
    task.uuid = uuid();
    cellFor(task, 'durations');
    this.tasks = [...this.tasks, task];
    write('tasks', this.tasks);
    addTaskToAsyncStorage(task).catch(() => {
      console.info(`Unable to add task ${task.uuid} to async storage`);
    });
    try {
      Telegram.WebApp.HapticFeedback.notificationOccurred('success');
    } catch (e) {
      // FINE
    }
  };
  onAddDuration = (task: Task, duration: TaskDuration) => {
    this.addDuration(task, duration);
  };
  addDuration = (
    task: Task,
    duration: TaskDuration,
    skipCloudSync: boolean = false,
  ) => {
    task.durations = [...task.durations, duration];
    this.selectedTask = null;

    console.log(this.tasks);
    write('tasks', this.tasks);
    if (skipCloudSync) {
      return;
    }
    requestAnimationFrame(() => {
      const btn = document.getElementById(`task-button-${task.uuid}`);
      if (btn) {
        btn.focus();
      }
    })
    addTaskDurationToAsyncStorage(task.uuid, duration).catch(() => {
      console.info(`Unable to add task duration to async storage`);
    });
    try {
      Telegram.WebApp.HapticFeedback.notificationOccurred('success');
    } catch (e) {
      // FINE
    }
  };
  get inTelegram() {
    return (
      typeof Telegram !== 'undefined' && Telegram.WebApp.platform !== 'unknown'
    );
  }
  get showHeader() {
    return !this.inTelegram;
  }
  get showFooter() {
    return !this.inTelegram;
  }
  async syncStorages() {
    let cloudValues = await loadTasksFromAsyncStorage();
    let removedUids = await getRemovedTaskIdsFromAsyncStorage();
    let existingTasks = this.tasks;
    const tasksToRemoveLocally = existingTasks.filter((t) => {
      return removedUids.includes(t.uuid);
    });
    const selectedTaskUid = this.selectedTask?.uuid;
    tasksToRemoveLocally.forEach((t) => {
      if (t.uuid === selectedTaskUid) {
        this.selectedTask = null;
      }
      this.removeTask(t, true);
    });
    existingTasks = existingTasks.filter(
      (t) => !tasksToRemoveLocally.includes(t),
    );

    if (!cloudValues.length) {
      // initial sync case - no remote data
      await saveTasksToAsyncStorage(existingTasks);
      return;
    }
    cloudValues.forEach((t) => {
      // make cloud durations reactive
      cellFor(t, 'durations');
    });
    const newTasksFromCloud = cloudValues.filter((cloudTask) => {
      return !existingTasks.find((t) => {
        return t.uuid === cloudTask.uuid;
      });
    });
    if (newTasksFromCloud.length) {
      // if new items appears from cloud - add it locally
      this.tasks = [...existingTasks, ...newTasksFromCloud];
    }
    const existingItemsDurationSet: Map<string, Set<string>> = new Map();
    const cloudItemsDurationSet: Map<string, Set<string>> = new Map();

    // list of all durations for existing tasks
    existingTasks.forEach((t) => {
      const sDurations = t.durations.map((d) => {
        return JSON.stringify(d);
      });
      existingItemsDurationSet.set(t.uuid, new Set(sDurations));
    });
    // list of all durations for cloud tasks
    cloudValues.forEach((t) => {
      const sDurations = t.durations.map((d) => {
        return JSON.stringify(d);
      });
      cloudItemsDurationSet.set(t.uuid, new Set(sDurations));
    });

    const durationsToAddToCloud: Array<[string, TaskDuration]> = [];
    const durationsToAddToLocal: Array<[string, TaskDuration]> = [];
    const tasksToAddToCloud: string[] = [];

    existingItemsDurationSet.forEach((value, key) => {
      const cloudRef = cloudItemsDurationSet.get(key) || null;
      if (cloudRef) {
        value.forEach((serializedDuration) => {
          if (cloudRef.has(serializedDuration)) {
            // duration fine, exist in cloud and locally
          } else {
            // duration exist locally, but not exists in cloud
            durationsToAddToCloud.push([
              key,
              JSON.parse(serializedDuration) as TaskDuration,
            ]);
          }
        });
      } else {
        // no cloud ref found for task, need sync here
        tasksToAddToCloud.push(key);
      }
    });

    cloudItemsDurationSet.forEach((value, key) => {
      const localRef = existingItemsDurationSet.get(key) || null;
      if (localRef) {
        value.forEach((serializedDuration) => {
          if (localRef.has(serializedDuration)) {
            // duration fine, exist in cloud and locally
          } else {
            // duration exist locally, but not exists in cloud
            durationsToAddToLocal.push([
              key,
              JSON.parse(serializedDuration) as TaskDuration,
            ]);
          }
        });
      } else {
        // no local task ref found, this case already covered by initial merge
      }
    });
    durationsToAddToLocal.forEach(([taskId, duration]) => {
      const task = this.tasks.find((t) => t.uuid === taskId);
      if (!task) {
        return;
      }
      this.addDuration(task, duration, true);
    });
    for (const [uuid, duration] of durationsToAddToCloud) {
      try {
        await addTaskDurationToAsyncStorage(uuid, duration);
      } catch (e) {
        console.info(
          `unable to cloud-sync duration for task: ${uuid}, ${JSON.stringify(
            duration,
          )}`,
        );
      }
    }
    for (const taskId of tasksToAddToCloud) {
      try {
        await addTaskToAsyncStorage(
          existingTasks.find((t) => t.uuid === taskId)!,
        );
      } catch (e) {
        console.info(`unable to add missing task to cloud-storage: ${taskId}`);
      }
    }
  }
  onAppLoad = (_e: unknown) => {
    this.syncStorages().catch((e) => {
      console.info(`Unable to sync storage data`, e);
    }).then(() => {
      setTimeout(() => {
        // try to sync again
        this.onAppLoad(null);
      }, 30000);
    })
  };
  @tracked taskDetailsToggled = false;
  onToggleTaskDetails = (e: Event) => {
    const details = e.target as HTMLDetailsElement;
    this.taskDetailsToggled = details.open;
  };
  <template>
    <section class='container mx-auto p-4 overflow-hidden' {{this.onAppLoad}}>
      {{#if this.showHeader}}
        <h1 class='text-lg text-cyan-500 font-bold mb-2'>Track It</h1>
      {{/if}}

      <details class='m-2 w-full'>
        <summary class='cursor-pointer text-cyan-300'>New task</summary>
        <AddTask @addTask={{this.addTask}} />
      </details>

      {{#if this.selectedTask}}

        <AddDuration
          @task={{this.selectedTask}}
          @addDuration={{this.onAddDuration}}
          @onClose={{fn this.selectTask null}}
          @showForm={{not this.taskDetailsToggled}}
        >

          <details class='m-2 w-full min-w-60' {{on 'toggle' this.onToggleTaskDetails}}>
            <summary
              class='cursor-pointer text-cyan-300'
            >{{this.selectedTask.label}}</summary>
            <div class='p-2'>
              <TaskDetails
                @task={{this.selectedTask}}
                @onClickRemove={{fn this.onRemoveTask this.selectedTask}}
                @onClickEdit={{fn this.editTask this.selectedTask}}
              />
            </div>
          </details>
        </AddDuration>

      {{/if}}

      <TaskList
        @tasks={{this.tasks}}
        @selectTask={{this.selectTask}}
        @removeTask={{this.onRemoveTask}}
      />

    </section>
    {{#if this.showFooter}}
      <footer><p class='text-center text-xs text-gray-500'>
          Check on
          <a
            href='https://github.com/lifeart/track-it/'
            class='text-blue-500'
          >GitHub</a></p></footer>
    {{/if}}
  </template>
}
