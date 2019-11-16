import React from "react";
import { strings } from "../../i18n";
import { SelectInput } from "../room/settings/widgets";
import Select from "react-select";
import { client } from "../../helper/webSockets";
import { PushPinSVG } from "../../helper/svgs";


const colors = ['#FF6900', '#FCB900', '#7BDCB5', '#00D084', '#8ED1FC', '#0693E3', '#ABB8C3', '#EB144C', '#F78DA7', '#9900EF'];

const options = colors.map(col => {
    return { value: col, label: <img src={PushPinSVG({ color: col })} /> }
}
);

export const ListPins = (player, onPinChange) => {

    return <Select options={options} defaultValue={options[0]} onChange={onPinChange} />
}

