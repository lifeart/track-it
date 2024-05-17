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
    this.selectedTask = task;
  };
  addTask = (task: Task) => {
    this.tasks = [...this.tasks, task];
    write('tasks', this.tasks);
  };
  addDuration = (task: Task, duration: { time: number; date: string }) => {
    const updatedTask = {
      ...task,
      durations: [...task.durations, duration],
    };
    this.tasks = this.tasks.map((t) => (t === task ? updatedTask : t));
    console.log(this.tasks);
    write('tasks', this.tasks);
  };
  <template>
    <section>
      <div class='container mx-auto p-4'>
        <h1 class='text-2xl font-bold mb-4'>TrackIt</h1>

        <details class='m-2 w-full'>
          <summary class='cursor-pointer text-blue-500'>New task</summary>
          <AddTask @addTask={{this.addTask}} />
        </details>

        {{#if this.selectedTask}}
          <AddDuration
            @task={{this.selectedTask}}
            @addDuration={{this.addDuration}}
          />
        {{/if}}

        <TaskList @tasks={{this.tasks}} @selectTask={{this.selectTask}} />
       
      </div>

    </section>
  </template>
}
