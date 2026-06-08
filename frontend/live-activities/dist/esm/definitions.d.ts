export interface LiveActivitiesPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
