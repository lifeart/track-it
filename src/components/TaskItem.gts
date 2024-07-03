import { Component } from '@lifeart/gxt';
import type { Task } from '../types/app';
import { formatDuration, monthlyTime } from '../helpers';

interface TaskItemArgs {
  task: Task;
  selectTask: () => void;
  removeTask: () => void;
}

export class TaskItem extends Component<{
  Args: TaskItemArgs;
}> {
  selectTask = () => {
    this.args.selectTask();
  };
  <template>
    <div class='cursor-pointer flex m-2 flex-auto gap-2'>
      <div>
        <button
          type='button'
          class='text-lg font-semibold flex items-center text-white bg-blue-900 p-2 rounded-md'
          {{on 'click' this.selectTask}}
          id="task-button-{{@task.uuid}}"
        >{{@task.label}}
          {{#if (monthlyTime @task)}}
            <badge
              class='ml-2 flex pl-2 pr-2 text-sm bg-blue-500 text-white rounded-full p-1'
            >{{formatDuration (monthlyTime @task)}}</badge>
          {{/if}}
        </button>
      </div>
    </div>
  </template>
}
