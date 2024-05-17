import { Component, tracked } from '@lifeart/gxt';

import { AddDuration } from './components/AddDuration';
import { AddTask } from './components/AddTask';
import type { Task } from './types/app';
import { TaskList } from './components/TaskList';
import { read, write } from './utils/persisted';

export default class App extends Component {
  @tracked tasks: Task[] = read('tasks', []);
  @tracked selectedTask: Task | null = null;
  selectTask = (task: Task) => {
    if (this.selectedTask === task) {
      this.selectedTask = null;
      return;
    }
    this.selectedTask = task;
  };
  removeTask = (task: Task) => {
    this.tasks = this.tasks.filter((t) => t !== task);
    write('tasks', this.tasks);
  };
  addTask = (task: Task) => {
    this.tasks = [...this.tasks, task];
    write('tasks', this.tasks);
  };
  addDuration = (task: Task, duration: { time: number; date: string, note: string }) => {
    const updatedTask = {
      ...task,
      durations: [...task.durations, duration],
    };
    this.tasks = this.tasks.map((t) => (t === task ? updatedTask : t));
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
        />

      {{/if}}

      <TaskList 
        @tasks={{this.tasks}} 
        @selectTask={{this.selectTask}}
        @removeTask={{this.removeTask}}
       />

    </section>
  </template>
}
