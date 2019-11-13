import React, { useState } from "react";
import { User, Zap } from "react-feather";
import { client } from "../../helper/webSockets";
import { isRoomLeader } from "../../shared/selectors";
import { UserName } from "../game/scoreBoard/widgets";
import { HorizontalAlignment } from "../uiWidgets/HorizontalAlignment";
import { GetReadyButton, MuteButton, PlayerStatusButton } from "./buttons";
import { UserColorPicker } from "./colorPicker";
import { ListPins } from "./listPins";
import { changeName } from "./index";
import { ColorPickerWrapper, UserColor, UserIcon, UserListingRow } from "./widgets";

export const PlayerRow = ({ player, onColorChange, onPinChange, room }) => {
    const audioMuted = localStorage.getItem("audioMuted") !== null;
    const [colorPicker, toggleColorPicker] = useState(false);
    const [muted, setMuted] = useState(audioMuted);

    const isLeader = isRoomLeader(room);
    const userIcon = isLeader ? <Zap /> : <User />;
    const isCurrentPlayer = client.auth._id === player.id;

    const colorPickerComponent = (
        <UserColorPicker
            onColorChange={onColorChange}
            player={player}
            toggleColorPicker={toggleColorPicker}
        />
    );
    const PinPickerComponent = (
        <ListPins
            onPinChange={onPinChange}
            player={player}
        />
    );


    const toggleMute = () => {
        if (audioMuted) {
            localStorage.removeItem("audioMuted");
        }

        if (!audioMuted) {
            localStorage.setItem("audioMuted", "1");
        }

        return setMuted(!audioMuted);
    };

    const handleUserNameClick = () => {
        if (!isCurrentPlayer) {
            return;
        }
        changeName();
    };

    const handleUserColorClick = () => {
        if (!isCurrentPlayer) {
            return;
        }
        toggleColorPicker(!colorPicker);
    };

    return (
        <UserListingRow isUser={isCurrentPlayer} key={player.id}>
            <HorizontalAlignment>
                <UserIcon className={"userIcon"}>{userIcon}</UserIcon>
                <UserName onClick={handleUserNameClick}>
                    <img alt="Player avatar" src={player.avatarUrl} width={28} />
                    <span style={{ fontSize: "24px" }}>{player.displayName}</span>
                </UserName>
                <ColorPickerWrapper>
                    <UserColor onClick={handleUserColorClick} style={{ background: player.color }} />
                    {colorPicker && colorPickerComponent}
                </ColorPickerWrapper>
                {PinPickerComponent}
            </HorizontalAlignment>
            <HorizontalAlignment>
                {isCurrentPlayer && <MuteButton muted={muted} toggleMute={toggleMute} />}
                {isCurrentPlayer && <GetReadyButton player={player} />}
                {!isCurrentPlayer && <PlayerStatusButton player={player} room={room} />}
            </HorizontalAlignment>
        </UserListingRow >
    );
};
