/* eslint-disable */
export interface LiveActivitiesPlugin {
  start(options: TimerState): Promise<{ activityId: string }>;
  update(options: TimerState & { activityId: string }): Promise<void>;
  end(options: { activityId: string }): Promise<void>;
}

export interface TimerState {
  startedAt: number;
  endsAt: number | null;
  countsDown: boolean;
}
