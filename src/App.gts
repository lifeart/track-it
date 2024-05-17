import { Component, tracked } from '@lifeart/gxt';

import { AddDuration } from './components/AddDuration';
import { AddTask } from './components/AddTask';
import type { Task } from './types/app';
import { TaskList } from './components/TaskList';

export default class App extends Component {
  @tracked tasks: Task[] = [];
  @tracked selectedTask: Task | null = null;
  selectTask = (task: Task) => {
    this.selectedTask = task;
  };
  addTask = (task: Task) => {
    this.tasks = [...this.tasks, task];
  };
  addDuration = (task: Task, duration: { time: number; date: string }) => {
    const updatedTask = {
      ...task,
      durations: [...task.durations, duration],
    };
    this.tasks = this.tasks.map((t) => (t === task ? updatedTask : t));
  };
  <template>
    <section>
      <div class='container mx-auto p-4'>
        <h1 class='text-2xl font-bold mb-4'>Time Tracker</h1>
        <TaskList @tasks={{this.tasks}} @selectTask={{this.selectTask}} />
        <AddTask @addTask={{this.addTask}} />
        {{#if this.selectedTask}}
          <AddDuration
            @task={{this.selectedTask}}
            @addDuration={{this.addDuration}}
          />
        {{/if}}
      </div>

    </section>
  </template>
}
