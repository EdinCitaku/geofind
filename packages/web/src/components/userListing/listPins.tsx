import React from "react";
import { strings } from "../../i18n";
import { SelectInput } from "../room/settings/widgets";
import Select from "react-select";
import { client } from "../../helper/webSockets";



var ping1 = require('../../assets/ping1.png');
var ping2 = require('../../assets/ping2.png');

const options = [
    { value: 'ping1', label: <img src={ping1} /> },
    { value: 'ping2', label: <img src={ping2} /> },
]

export const ListPins = (player, onPinChange) => {

    return <Select options={options} defaultValue={options[0]} onChange={onPinChange} />
}

