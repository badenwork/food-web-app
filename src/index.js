import './main.css';
import './UI.css';
import './UI/KeyHelper.css';
import './Page/Products.css';
import './Page/Order.css';
import './Page/OrderConfirm.css';
import './Page/Cook.css';
import './Page/Vending.css';
import './Page/Calibration.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const flags = {
    "hostname": location.hostname,
    "name": "name"
}

var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags
});

console.log("app", app, app.ports);


let socket;
function open(url) {
    console.log("open");
    socket = new WebSocket(url);
    socket.onopen = () => {
        console.log("onopen");
        app.ports.websocketOpened.send(true);
    }
    socket.onmessage = message => {
        console.log("onmessage", [message.data, JSON.parse(message.data)]);
        app.ports.websocketIn.send(message.data);
    }
    socket.onerror = (error) => {
        console.log("onerror", error.message);
    };
    socket.onclose = () => {
        console.log("onclose");
        app.ports.websocketOpened.send(false);
        socket = null;
        setTimeout(function() {
            open(url);
        }, 1000);
    }
}

let debug_tm = new Date();

app.ports.websocketOpen.subscribe(url => {
    open(url);
});

app.ports.debugMessage.subscribe(text => {
    const tm = new Date();
    // const diff = Math.round((((tm|0) - (debug_tm|0)) / 1000 + Number.EPSILON) * 10) / 10;
    const diff = (((tm|0) - (debug_tm|0)) / 1000 + Number.EPSILON).toFixed(1);
    debug_tm = tm;
    app.ports.debugIn.send(`[${tm.toLocaleTimeString('ru-RU')}+${diff}] : ${text}`);
});

/*
app.ports.websocketOut.subscribe(message => {
    console.log("websocketOut", [message]);
    if (socket && socket.readyState === 1) {
        socket.send(JSON.stringify(message));
    } else {
        console.log("sending canceled", [message, socket]);
    }
});
*/

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
// serviceWorker.register();
serviceWorker.unregister();
