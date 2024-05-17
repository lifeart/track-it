import { Component, tracked } from '@lifeart/gxt';
import { parseISO, startOfMonth, isAfter } from 'date-fns';
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
    const startOfCurrentMonth = startOfMonth(new Date());

    return this.args.task.durations
      .filter((duration) =>
        isAfter(parseISO(duration.date), startOfCurrentMonth),
      )
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
        <button
          type='button'
          class='text-xl font-semibold'
          {{on 'click' this.toggleDetails}}
        >{{@task.label}}</button>

        {{#if this.showDetails}}
          <p>{{@task.description}}</p>
          <p>Total time spent: {{this.formatDuration this.totalTime}}</p>
          <p>Time spent this month: {{this.formatDuration this.monthlyTime}}</p>
          <div class='mt-2'>
            <h3 class='font-semibold'>Timetable:</h3>
            <ul>
              {{#each @task.durations as |duration|}}
                <li>{{duration.date}}:
                  {{this.formatDuration duration.time}}
                </li>
              {{/each}}
            </ul>
          </div>
        {{/if}}
      </div>
    </li>
  </template>
}
