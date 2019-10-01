import {sharedHistory} from "./sharedHistory";
import {
    LOBBIES_LIST,
    LOBBY_JOIN,
    LOBBY_UPDATE,
    LOBBY_MESSAGE,
    GAME_UPDATE,
    USER_CONNECTED,
    USER_LIST_LOBBY,
    USER_DISCONNECTED
} from "../actions/types";

declare const io : any;

export const webSocketConnection = io(process.env.ENVIRONMENT === "production" ? "https://gameserver.geofind.io" : "http://localhost:3888");

export const initWebSockets = (store) => {
    let timer = false;
    webSocketConnection.on("connect", () => {
        if (timer){
            clearInterval(timer);
        }
        webSocketConnection.emit('welcome', localStorage.getItem("user") ? JSON.parse(localStorage.getItem("user")) : {});
    });
    // TODO: extract into config.
    webSocketConnection.on('welcome', (data) => {
        store.dispatch({ type: USER_CONNECTED, payload: data})
    });

    webSocketConnection.on("disconnect", () => {
        store.dispatch({ type: USER_DISCONNECTED, payload: false})
        timer = setInterval(() => {
            webSocketConnection.connect();
        }, 500);
    })


    // TODO: cleanup
    try {
        if (localStorage.getItem("user")){
            webSocketConnection.emit("userLogon", JSON.parse(localStorage.getItem("user")));
        }
    } catch (e){

    }

    webSocketConnection.on('lobbyList', (lobbies) => {
        console.log("LobbyList: ", lobbies);
        store.dispatch({ type: LOBBIES_LIST, payload: lobbies });
    });

    webSocketConnection.on("userListLobby", (users) => {
        console.log(users);
        store.dispatch({ type: USER_LIST_LOBBY, payload: users })
    });

    webSocketConnection.on("gameUpdate", (game) => {
        store.dispatch({ type: GAME_UPDATE, payload: game })
    });

    webSocketConnection.on("updateLobby", (lobby) => {
       store.dispatch({type: LOBBY_UPDATE, payload: lobby })
    });

    /*webSocketConnection.on("userChatMessage", (message) => {
        store.dispatch({type: LOBBY_MESSAGE, payload: message })
    });*/

    webSocketConnection.on("lobbyCreated", (lobby) => {
       sharedHistory.push(`/lobby_${lobby.id}`)
    });

    webSocketConnection.on("lobbyNotFound", (lobby) => {
        console.error("Lobby not found.");
        sharedHistory.push(`/`)
    });

    webSocketConnection.on("gameCreated", (game) => {
        sharedHistory.push(`/game_${game.id}`);
    })

    webSocketConnection.on("lobbyJoined", (lobby) => {
       store.dispatch({type: LOBBY_JOIN, payload: lobby})
    });

    webSocketConnection.on("lobbyLeft", (lobby) => {
        sharedHistory.push(`/`)
    });

    webSocketConnection.on('serverError', (err) => {
        console.error("ServerError: ", err);
    });
};

