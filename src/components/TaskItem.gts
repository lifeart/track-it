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
    if (hours === 0) {
      return `${minutes}m`;
    } else if (minutes === 0) {
      return `${hours}h`;
    }
    return `${hours}h ${minutes}m`;
  }
  formatDate: (date: string) => string = (date) => {
    const currentLocale = navigator.language;
    return new Date(date).toLocaleDateString(currentLocale, {
      dateStyle: 'short',
    });
  };

  <template>
    <div class='cursor-pointer flex m-2 flex-auto gap-2'>
      <div>
        <button
          type='button'
          class='text-sm font-semibold text-white bg-blue-900 p-2 rounded-md'
          {{on 'dblclick' this.toggleDetails}}
          {{on 'click' this.selectTask}}
        >{{@task.label}}
          {{#if this.monthlyTime}}
            <badge
              class='ml-2 bg-blue-500 text-white rounded-full p-1'
            >{{this.formatDuration this.monthlyTime}}</badge>
          {{/if}}
        </button>
        {{#if this.showDetails}}
          <p>{{@task.description}}</p>
          <p>Total time spent: {{this.formatDuration this.totalTime}}</p>
          <p>Time spent this month: {{this.formatDuration this.monthlyTime}}</p>
          <div class='mt-2'>
            <h3 class='font-semibold'>Timetable:</h3>
            <table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Note</th>
                </tr>
              </thead>
              <tbody>
                {{#each @task.durations as |duration|}}
                  <tr>
                    <td>{{this.formatDate duration.date}}</td>
                    <td>{{this.formatDuration duration.time}}</td>
                    <td>{{duration.note}}</td>
                  </tr>
                {{/each}}
              </tbody>
            </table>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}
