import { Component, tracked } from '@lifeart/gxt';
import { parseISO, startOfMonth, isAfter } from 'date-fns';
import type { Task } from '../types/app';

interface TaskItemArgs {
  task: Task;
  selectTask: () => void;
  removeTask: () => void;
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

  formatDuration(raw: number): string {
    const milliseconds = Math.abs(raw);
    const hours = Math.floor(milliseconds / 3600000);
    const minutes = Math.floor((milliseconds % 3600000) / 60000);
    const prefix = raw < 0 ? '-' : '';
    if (hours === 0) {
      return `${prefix}${minutes}m`;
    } else if (minutes === 0) {
      return `${prefix}${hours}h`;
    }
    return `${prefix}${hours}h ${minutes}m`;
  }
  formatDate: (date: string) => string = (date) => {
    const currentLocale = navigator.language;
    return new Date(date).toLocaleDateString(currentLocale, {
      dateStyle: 'short',
    });
  };

  onClickRemove = () => {
    if (confirm('Are you sure you want to remove this task?')) {
      this.args.removeTask();
    }
  };
  clickCount = 0;
  handleClick = () => {
    this.clickCount += 1;
    if (this.clickCount === 1) {
      this.selectTask();
    } else if (this.clickCount === 2) {
      this.toggleDetails();
      this.clickCount = 0;
    }
  };
  <template>
    <div class='cursor-pointer flex m-2 flex-auto gap-2'>
      <div>
        <button
          type='button'
          class='text-lg font-semibold  flex items-center text-white bg-blue-900 p-2 rounded-md'
          {{on 'click' this.handleClick}}
        >{{@task.label}}
          {{#if this.monthlyTime}}
            <badge
              class='ml-2 flex pl-2 pr-2 text-sm bg-blue-500 text-white rounded-full p-1'
            >{{this.formatDuration this.monthlyTime}}</badge>
          {{/if}}
        </button>
        {{#if this.showDetails}}
          <section class='text-slate-100 p-2'>
            <p>{{@task.description}}</p>
            <p>Total time spent: {{this.formatDuration this.totalTime}}</p>
            <p>Time spent this month:
              {{this.formatDuration this.monthlyTime}}</p>
            <div class='mt-2'>
              <table class='table-auto border-collapse border border-slate-500'>
                <thead>
                  <tr>
                    <th class='p-2'>Date</th>
                    <th class='p-2'>Time</th>
                    <th class='p-2'>Note</th>
                  </tr>
                </thead>
                <tbody>
                  {{#each @task.durations as |duration|}}
                    <tr>
                      <td class='p-2'>{{this.formatDate duration.date}}</td>
                      <td class='p-2'>{{this.formatDuration duration.time}}</td>
                      <td class='p-2'>{{duration.note}}</td>
                    </tr>
                  {{/each}}
                </tbody>
              </table>
            </div>
            <button
              type='button'
              class='mt-2 text-lg font-semibold text-white bg-red-900 p-2 rounded-md'
              {{on 'click' this.onClickRemove}}
            >Remove Tag</button>
          </section>
        {{/if}}
      </div>
    </div>
  </template>
}
