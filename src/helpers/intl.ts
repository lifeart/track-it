const en = {
  msg_confirm_task_removal: 'Are you sure you want to remove this task?',
  msg_task_with_this_label_already_exists:
    'Task with label {label} already exists',
  app_name: 'Track It',
  new_task: 'New Task',
  check_on: 'Check on',
  git_hub: 'GitHub',
  placeholder_duration: 'Enter time (e.g., 1h20m)',
  placeholder_notes: 'Notes',
  add: 'Add',
  add_task: 'Add Task',
  task_description: 'Task Description',
  task_label: 'Task Label',
  // Total time spent
  total_time_spent: 'Total time spent',
  // Time spent this month
  time_spent_this_month: 'Time spent this month',
  // Date
  date: 'Date',
  // Time

  time: 'Time',
  // Note
  note: 'Note',
  // Remove Task
  remove_task: 'Remove Task',
  // Edit Task
  edit_task: 'Edit Task',
  m: 'm',
  h: 'h',
  save_task: 'Save Task',
};

const ru = {
  msg_confirm_task_removal: 'Вы уверены, что хотите удалить эту задачу?',
  msg_task_with_this_label_already_exists:
    'Задача с меткой {label} уже существует',
  app_name: 'Track It',
  new_task: 'Новая задача',
  check_on: 'Проверить на',
  git_hub: 'GitHub',
  placeholder_duration: 'Время (прим., 1ч20м)',
  placeholder_notes: 'Заметка',
  add: 'Добавить',
  add_task: 'Добавить задачу',
  save_task: 'Сохранить задачу',
  task_description: 'Описание задачи',
  task_label: 'Метка задачи',
  total_time_spent: 'Общее затраченное время',
  time_spent_this_month: 'Время, затраченное в этом месяце',
  date: 'Дата',
  time: 'Время',
  note: 'Заметка',
  remove_task: 'Удалить задачу',
  edit_task: 'Редактировать задачу',
  h: 'ч',
  m: 'м',
};

const isRu =
  Intl.DateTimeFormat().resolvedOptions().timeZone === 'Europe/Moscow';
export const t = isRu ? ru : en;

export function fixDuration(str: string): string {
  const replaceMap = {
    секунда: 's',
    секунды: 's',
    секунду: 's',
    секунд: 's',
    минута: 'm',
    минуты: 'm',
    минуту: 'm',
    часов: 'h',
    минут: 'm',
    часа: 'h',
    часы: 'h',
    час: 'h',
    мин: 'm',
    сек: 's',
    ч: 'h',
    м: 'm',
    с: 's',
  };

  for (const [key, value] of Object.entries(replaceMap)) {
    str = str.replace(new RegExp(key, 'g'), value);
  }
  console.log(str);
  return str;
}
