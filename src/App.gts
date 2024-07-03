import { Component, cellFor, tracked } from '@lifeart/gxt';

import { AddDuration } from './components/AddDuration';
import { AddTask } from './components/AddTask';
import { EditTask } from './components/EditTask';
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
  saveTasksListToAsyncStorage,
} from './utils/cloud';
import { t } from './helpers/intl';

const space = () => document.createTextNode('\u00A0');

export default class App extends Component {
  @tracked tasks: Task[] = read('tasks', []).map((task: Task) => {
    if (!task.uuid) {
      task.uuid = uuid();
    }
    cellFor(task, 'durations');
    return task;
  });
  @tracked selectedTaskId: string | null = null;
  @tracked taskToEditId: string | null = null;
  get selectedTask() {
    return this.tasks.find((t) => t.uuid === this.selectedTaskId) || null;
  }
  get taskToEdit() {
    return this.tasks.find((t) => t.uuid === this.taskToEditId) || null;
  }
  selectTask = (task: Task | null) => {
    if (task && this.selectedTask === task) {
      this.selectedTaskId = null;
      return;
    }
    this.selectedTaskId = task?.uuid || null;
    this.taskDetailsToggled = false;
    try {
      Telegram.WebApp.HapticFeedback.selectionChanged();
    } catch (e) {
      // FINE
    }
  };
  editTask = (task: Task) => {
    this.taskToEditId = task.uuid;
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
  alert(prompt: string) {
    if (this.inTelegram) {
      try {
        Telegram.WebApp.HapticFeedback.impactOccurred('light');
      } catch (e) {
        // FINE
      }
      return new Promise((resolve) => {
        Telegram.WebApp.showAlert(prompt, () => resolve(void 0));
      });
    }
    return alert(prompt);
  }
  onRemoveTask = (task: Task) => {
    this.removeTask(task);
  };
  removeTask = async (task: Task, skipCloudSync = false) => {
    if (!skipCloudSync) {
      if (!(await this.confirm(t.msg_confirm_task_removal))) {
        return;
      }
    }
    this.tasks = this.tasks.filter((t) => t.uuid !== task.uuid);
    if (this.selectedTaskId === task.uuid) {
      this.selectedTaskId = null;
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
  saveTask = async (task: Task) => {
    const tasksWithSameLebel = this.tasks.find((t) => t.label === task.label);
    if (tasksWithSameLebel && tasksWithSameLebel?.uuid !== task.uuid) {
      try {
        Telegram.WebApp.HapticFeedback.notificationOccurred('error');
      } catch (e) {
        // FINE
      }
      this.alert(
        t.msg_task_with_this_label_already_exists.replace(
          '{label}',
          task.label,
        ),
      );
      return;
    }
    cellFor(task, 'durations');
    this.tasks = [...this.tasks.filter((t) => t !== this.taskToEdit), task];
    this.taskToEditId = null;
    this.selectedTaskId = task.uuid;
    write('tasks', this.tasks);
    saveTasksListToAsyncStorage(this.tasks).catch(() => {
      console.info(`Unable to add task ${task.uuid} to async storage`);
    });
    try {
      Telegram.WebApp.HapticFeedback.notificationOccurred('success');
    } catch (e) {
      // FINE
    }
  };
  addTask = async (task: Task) => {
    const tasksWithSameLebel = this.tasks.find((t) => t.label === task.label);
    if (tasksWithSameLebel) {
      try {
        Telegram.WebApp.HapticFeedback.notificationOccurred('error');
      } catch (e) {
        // FINE
      }
      this.alert(
        t.msg_task_with_this_label_already_exists.replace(
          '{label}',
          task.label,
        ),
      );
      return;
    }
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
    this.selectedTaskId = null;

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
    });
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
        this.selectedTaskId = null;
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
    this.fixLocalTaskNames(cloudValues);
  }
  fixLocalTaskNames(tasks: Task[]) {
    const localTasks = this.tasks;
    const tasksToFix = tasks.filter((cloudTask) => {
      const localTask = localTasks.find((t) => t.uuid === cloudTask.uuid);
      return (
        localTask &&
        (localTask.label !== cloudTask.label ||
          localTask.description !== cloudTask.description)
      );
    });
    this.tasks = this.tasks.map((t) => {
      const cloudTask = tasksToFix.find((ct) => ct.uuid === t.uuid);
      if (cloudTask) {
        cloudTask.durations = t.durations;
        return cloudTask;
      }
      return t;
    });
  }
  onAppLoad = (_e: unknown) => {
    this.syncStorages()
      .catch((e) => {
        console.info(`Unable to sync storage data`, e);
      })
      .then(() => {
        setTimeout(() => {
          // try to sync again
          this.onAppLoad(null);
        }, 30000);
      });
  };
  @tracked taskDetailsToggled = false;
  onToggleTaskDetails = (e: Event) => {
    const details = e.target as HTMLDetailsElement;
    this.taskDetailsToggled = details.open;
  };
  <template>
    <section class='container mx-auto p-4 overflow-hidden' {{this.onAppLoad}}>
      {{#if this.showHeader}}
        <h1 class='text-lg text-cyan-500 font-bold mb-2'>{{t.app_name}}</h1>
      {{/if}}

      <details class='m-2 w-full'>
        <summary class='cursor-pointer text-cyan-300'>{{t.new_task}}</summary>
        <AddTask @addTask={{this.addTask}} />
      </details>

      {{#if this.selectedTask}}

        <AddDuration
          @task={{this.selectedTask}}
          @addDuration={{this.onAddDuration}}
          @onClose={{fn this.selectTask null}}
          @showForm={{not this.taskDetailsToggled}}
        >

          <details
            class='m-2 w-full min-w-64'
            {{on 'toggle' this.onToggleTaskDetails}}
          >
            <summary
              class='cursor-pointer text-cyan-300'
            >{{this.selectedTask.label}}</summary>
            <div class='p-2'>
              {{#if this.taskToEdit}}
                <EditTask
                  @task={{this.taskToEdit}}
                  @saveTask={{this.saveTask}}
                />
              {{else}}
                {{! NO TASK FOR EDIT }}
                {{! FIXME: IF TaskDetails rendered here, things breaking }}
              {{/if}}
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
          {{t.check_on}}{{space}}
          <a
            href='https://github.com/lifeart/track-it/'
            class='text-blue-500'
          >{{t.git_hub}}</a></p></footer>
    {{/if}}
  </template>
}
