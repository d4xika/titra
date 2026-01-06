import { LiveActivities } from 'live-activities';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    LiveActivities.echo({ value: inputValue })
}
