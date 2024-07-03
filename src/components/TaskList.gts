import { Component } from '@lifeart/gxt';
import type { Task } from '../types/app';
import { TaskItem } from './TaskItem';

export class TaskList extends Component<{
  Args: {
    tasks: Task[];
    selectTask: (task: Task) => void;
    removeTask: (task: Task) => void;
  };
}> {
  get sortedTasks() {
    return this.args.tasks.slice().sort((a, b) => {
      return a.label.localeCompare(b.label);
    });
  }
  <template>
    <div class='flex justify-between flex-wrap'>
      {{#each this.sortedTasks key="uuid" as |task|}}
        <TaskItem
          @task={{task}}
          @selectTask={{fn @selectTask task}}
          @removeTask={{fn @removeTask task}}
        />
      {{/each}}
    </div>
  </template>
}
