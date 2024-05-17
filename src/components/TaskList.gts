import { Component } from '@lifeart/gxt';
import type { Task } from '../types/app';
import { TaskItem } from './TaskItem';

export class TaskList extends Component<{
  Args: {
    tasks: Task[];
    selectTask: (task: Task) => void;
  };
}> {
  <template>
    <div>
      <ul>
        {{#each @tasks as |task|}}
          <TaskItem @task={{task}} @selectTask={{fn @selectTask task}} />
        {{/each}}
      </ul>
    </div>
  </template>
}
