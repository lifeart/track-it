import { Component, cell, cellFor, tracked } from '@lifeart/gxt';

import { AddDuration } from './components/AddDuration';
import { AddTask } from './components/AddTask';
import type { Task } from './types/app';
import { TaskList } from './components/TaskList';
import { read, write } from './utils/persisted';
import { TaskDetails } from './components/TaskDetails';

export default class App extends Component {
  @tracked tasks: Task[] = read('tasks', []).map((task) => {
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
  };
  editTask = (task: Task) => {
    console.log('edit', task);
  };
  removeTask = (task: Task) => {
    if (!confirm('Are you sure you want to remove this task?')) {
      return;
    }
    this.tasks = this.tasks.filter((t) => t !== task);
    if (this.selectedTask === task) {
      this.selectedTask = null;
    }
    write('tasks', this.tasks);
  };
  addTask = (task: Task) => {
    const taksWithSameLebel = this.tasks.find((t) => t.label === task.label);
    if (taksWithSameLebel) {
      alert(`Task with label ${task.label} already exists`);
      return;
    }
    cellFor(task, 'durations');
    this.tasks = [...this.tasks, task];
    write('tasks', this.tasks);
  };
  addDuration = (
    task: Task,
    duration: { time: number; date: string; note: string },
  ) => {

    task.durations = [...task.durations, duration];
    this.selectedTask = null;

    console.log(this.tasks);
    write('tasks', this.tasks);
  };
  <template>
    <section class='container mx-auto p-4'>
      <h1 class='text-lg text-cyan-500 font-bold mb-2'>Track It</h1>

      <details class='m-2 w-full'>
        <summary class='cursor-pointer text-cyan-300'>New task</summary>
        <AddTask @addTask={{this.addTask}} />
      </details>

      {{#if this.selectedTask}}

        <AddDuration
          @task={{this.selectedTask}}
          @addDuration={{this.addDuration}}
          @onClose={{fn this.selectTask null}}
        >

        <details class='m-2 w-full'>
          <summary class='cursor-pointer text-cyan-300'>{{this.selectedTask.label}}</summary>
          <div class='p-2 '>
            <TaskDetails
              @task={{this.selectedTask}}
              @onClickRemove={{fn this.removeTask this.selectedTask}}
              @onClickEdit={{fn this.editTask this.selectedTask}}
            />
          </div>
        </details>
        </AddDuration>

      {{/if}}

      <TaskList
        @tasks={{this.tasks}}
        @selectTask={{this.selectTask}}
        @removeTask={{this.removeTask}}
      />

    </section>
      <footer><p class='text-center text-xs text-gray-500'>
        Check on
        <a
          href='https://github.com/lifeart/track-it/'
          class='text-blue-500'
        >GitHub</a></p></footer>
  </template>
}
