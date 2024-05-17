import { Component } from '@lifeart/gxt';
import type { Task } from '../types/app';
import { formatDate, formatDuration, totalTime, monthlyTime } from '../helpers';

export class TaskDetails extends Component<{
  Args: {
    task: Task;
    onClickRemove: () => void;
  };
}> {
  <template>
    <section class='text-slate-100 p-2'>
      <p>{{@task.description}}</p>
      <p>Total time spent: {{formatDuration (totalTime @task)}}</p>
      <p>Time spent this month:
        {{formatDuration (monthlyTime @task)}}</p>
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
                <td class='p-2'>{{formatDate duration.date}}</td>
                <td class='p-2'>{{formatDuration duration.time}}</td>
                <td class='p-2'>{{duration.note}}</td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
      <button
        type='button'
        class='mt-2 text-lg font-semibold text-white bg-red-900 p-2 rounded-md'
        {{on 'click' @onClickRemove}}
      >Remove Tag</button>
    </section>
  </template>
}
