export interface TaskDuration {
  time: number;
  date: string;
  note: string;
}

export interface Task extends BaseTask {
  durations: TaskDuration[];
}

export interface BaseTask {
  uuid: string;
  label: string;
  description: string;
}
