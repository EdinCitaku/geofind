import React from "react";
import { strings } from "../../../i18n";
import { SelectInput } from "./widgets";
import Select from "react-select";

const options = [
    { value: 'chocolate', label: 'Chocolate' },
    { value: 'strawberry', label: 'Strawberry' },
    { value: 'vanilla', label: 'Vanilla' }
]

export const GameModeSelection = ({ onChange }) => {
    return (
        <SelectInput onChange={onChange}>
            <option value={"game_countries"}>{strings.gameModeCountries}</option>
            <option value={"game_streetview"}>{strings.gameModeStreetview}</option>
        </SelectInput>
    );
};
