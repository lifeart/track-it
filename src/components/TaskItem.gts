import { Component, tracked } from '@lifeart/gxt';
import { DateTime } from 'luxon';
import type { Task } from '../types/app';

interface TaskItemArgs {
  task: Task;
  selectTask: () => void;
}

export class TaskItem extends Component<{
  Args: TaskItemArgs;
}> {
  @tracked showDetails = false;

  get totalTime() {
    return this.args.task.durations.reduce(
      (sum, duration) => sum + duration.time,
      0,
    );
  }

  get monthlyTime() {
    const startOfMonth = DateTime.now().startOf('month');
    return this.args.task.durations
      .filter((duration) => DateTime.fromISO(duration.date) >= startOfMonth)
      .reduce((sum, duration) => sum + duration.time, 0);
  }

  toggleDetails = () => {
    this.showDetails = !this.showDetails;
  };

  selectTask = () => {
    this.args.selectTask();
  };

  formatDuration(milliseconds: number): string {
    const hours = Math.floor(milliseconds / 3600000);
    const minutes = Math.floor((milliseconds % 3600000) / 60000);
    return `${hours}h ${minutes}m`;
  }

  <template>
    <li class='p-2 border-b cursor-pointer' {{on 'click' this.selectTask}}>
      <div>
        <h2 class='text-xl font-semibold'>{{@task.label}}</h2>
        <p>{{@task.description}}</p>
        <p>Total time spent: {{this.formatDuration this.totalTime}} ms</p>
        <p>Time spent this month: {{this.formatDuration this.monthlyTime}} ms</p>
        <button
          class='mt-2 p-1 bg-gray-300'
          {{on 'click' this.toggleDetails}}
        >Details</button>
        {{#if this.showDetails}}
          <div class='mt-2'>
            <h3 class='font-semibold'>Timetable:</h3>
            <ul>
              {{#each @task.durations as |duration|}}
                <li>{{duration.date}}: {{this.formatDuration duration.time}} ms</li>
              {{/each}}
            </ul>
          </div>
        {{/if}}
      </div>
    </li>
  </template>
}
