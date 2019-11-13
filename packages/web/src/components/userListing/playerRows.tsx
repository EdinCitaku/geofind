import React from "react";
import { PlayerRow } from "./playerRow";

export const PlayerRows = ({ room, players, onColorChange, onPinChange }) => {
    const playerObjects = Object.keys(players).map((playerId) => players[playerId]);

    const playerRows = playerObjects.map((player) => {
        return (
            <div key={player.id}>
                <PlayerRow
                    onColorChange={onColorChange}
                    onPinChange={onPinChange}
                    room={room}
                    player={player}
                />
            </div>
        );
    });

    return <div>{playerRows}</div>;
};
