import { Component } from '@lifeart/gxt';
import type { Task } from '../types/app';
import { formatDate, formatDuration, totalTime, monthlyTime } from '@/helpers';
import { t } from '@/helpers/intl';

export class TaskDetails extends Component<{
  Args: {
    task: Task;
    onClickRemove: () => void;
    onClickEdit: () => void;
  };
}> {
  sortDurations(durations: Task['durations']) {
    return durations.sort((a, b) => {
      return new Date(b.date).getTime() - new Date(a.date).getTime();
    });
  }
  <template>
    <section class='text-slate-100 p-2'>
      <p>{{@task.description}}</p>
      <p>{{t.total_time_spent}}: {{formatDuration (totalTime @task)}}</p>
      <p>{{t.time_spent_this_month}}:
        {{formatDuration (monthlyTime @task)}}</p>
      <div class='mt-2 max-h-[50vh] overflow-x-scroll'>
        <table class='table-auto w-full border-collapse border border-sky-800'>
          <thead class='sticky top-0 bg-sky-950 border-b border-sky-800'>
            <tr>
              <th class='p-2'>{{t.date}}</th>
              <th class='p-2'>{{t.time}}</th>
              <th class='p-2'>{{t.note}}</th>
            </tr>
          </thead>
          <tbody>
            {{#each (this.sortDurations @task.durations) as |duration|}}
              <tr>
                <td class='p-2'>{{formatDate duration.date}}</td>
                <td class='p-2'>{{formatDuration duration.time}}</td>
                <td class='p-2'>{{duration.note}}</td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
      <div class='flex mt-2 justify-between gap-2'>
        <button
          type='button'
          class='flex-1 text-lg font-semibold text-white bg-red-900 p-2 rounded-md'
          {{on 'click' @onClickRemove}}
        >{{t.remove_task}}</button>
        <button
          type='button'
          class='flex-1 text-lg font-semibold text-white bg-blue-900 p-2 rounded-md'
          {{on 'click' (fn @onClickEdit)}}
        >{{t.edit_task}}</button>
      </div>

    </section>
  </template>
}
