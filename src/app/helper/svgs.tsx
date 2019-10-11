import React from "react";
// tslint:disable-next-line:no-submodule-imports
import {renderToString} from "react-dom/server";
import {ColorLuminance} from "./colorLuminance";

export const PushPinSVG = ({color, size = 30}) => {
    const encodedSVG = btoa(renderToString(<PushPin color={color} size={size} pinned={true}/>));
    return `data:image/svg+xml;charset=UTF-8;base64,${encodedSVG}`;
};

export const PushPin = ({color, size = 30, pinned = false}) => {
    const colorLight = ColorLuminance(color, -0.2);
    const colorLight2 = ColorLuminance(color, 0.2);
    const colorLight3 = ColorLuminance(color, -0.1);
    const pinStyle = pinned ? {
        transform: "rotate(-45deg)",
        transition: "transform ease-in-out 0.5s",
    } : {transition: "transform ease-in-out 0.5s"};
    return (
        <svg style={pinStyle} xmlns="http://www.w3.org/2000/svg" viewBox={`0 0 30 30`} width={size} height={size}>
            <path
                fill="#a3b7cc"
                d="M2 28.75L1 29 1.25 28 13.646 15.646 14.354 16.354z"
            />
            <path
                fill={colorLight2}
                d="M12.484,12.527c3.735-1.797,5.965-4.023,7.674-7.662l4.961,4.961 c-3.917,1.705-6.152,3.93-7.682,7.654L12.484,12.527z"
            />
            <path
                fill={colorLight}
                d="M20.298,5.713l3.958,3.958c-3.37,1.606-5.508,3.727-6.984,6.938l-3.945-3.945 C16.555,10.984,18.685,8.86,20.298,5.713 M20,4c-1.848,4.268-4.305,6.552-8.375,8.375l6,6C19.127,14.305,21.386,11.848,26,10L20,4 L20,4z"
            />
            <path
                fill={colorLight3}
                d="M26.152,10.5c-0.376,0-0.729-0.146-0.996-0.413l-5.244-5.244C19.646,4.578,19.5,4.224,19.5,3.849 s0.146-0.729,0.413-0.995l1.095-1.139l7.278,7.278l-1.132,1.088C26.881,10.354,26.527,10.5,26.152,10.5z"
            />
            <path
                fill={colorLight}
                d="M21.014,2.429l6.557,6.557l-0.779,0.749C26.621,9.906,26.394,10,26.152,10 c-0.242,0-0.47-0.094-0.642-0.266L20.266,4.49C20.094,4.319,20,4.091,20,3.849s0.094-0.47,0.28-0.656L21.014,2.429 M21,1 l-1.441,1.5c-0.745,0.745-0.745,1.952,0,2.697l5.244,5.244C25.175,10.814,25.664,11,26.152,11c0.488,0,0.976-0.186,1.348-0.559 L29,9L21,1L21,1z"
            />
            <g>
                <path
                    fill={colorLight3}
                    d="M6.707,13.339l0.795-0.795c0.673-0.673,1.568-1.043,2.52-1.043c0.951,0,1.846,0.371,2.519,1.043 l4.916,4.917c1.388,1.389,1.388,3.649,0,5.038l-0.796,0.795L6.707,13.339z"
                />
                <path
                    fill={colorLight}
                    d="M10.021,12c0.818,0,1.587,0.319,2.166,0.897l4.916,4.916c1.193,1.194,1.193,3.137,0,4.33 l-0.443,0.442l-9.247-9.247l0.442-0.442C8.434,12.319,9.204,12,10.021,12 M10.021,11c-1.04,0-2.079,0.397-2.873,1.19L6,13.339 L16.661,24l1.15-1.149c1.586-1.587,1.586-4.158,0-5.745l-4.916-4.916C12.101,11.397,11.061,11,10.021,11L10.021,11z"
                />
            </g>
        </svg>
    );
};

export const LogoSVG = () => {
    const encodedSVG = btoa(`<?xml version="1.0" encoding="UTF-8"?>
    <svg viewBox="0 0 512 512" width="48" height="48">
    <style type="text/css">
        .st0{fill:#D3D4D3;}
        .st1{fill:#AA8CC0;}
        .st2{fill:#6A6D71;}
        .st3{fill:#753D90;}
    </style>
    <path
    class="st0"
    d="m285.62 462.87c-6.14 6.72-11.5 12.47-15.8 17.03-2.91 2.78-6.96 4.48-11.46 4.48-4.54 0-8.62-1.73-11.53-4.55-4.29-4.53-9.63-10.26-15.74-16.95-39.36 2.64-68.07 10.86-68.07 20.59 0 11.87 42.69 21.49 95.34 21.49s95.34-9.62 95.34-21.49c0-9.75-28.72-17.96-68.08-20.6z"/><path class="st1" d="m258.36 108.62c47.99 0 87.03 38.91 87.03 86.74s-39.04 86.74-87.03 86.74-87.04-38.91-87.04-86.74 39.04-86.74 87.04-86.74zm0-26.97c-63.01 0-114.09 50.91-114.09 113.71s51.08 113.71 114.09 113.71 114.09-50.91 114.09-113.71-51.08-113.71-114.09-113.71z"/><path class="st2" d="m274.94 129.63c0.27 1.17 0.43 2.39 0.43 3.64 0 8.9-7.24 16.12-16.17 16.12s-16.17-7.22-16.17-16.12c0-1.4 0.2-2.75 0.54-4.05-29.99 6.72-52.4 33.4-52.4 65.32 0 36.98 30.09 66.96 67.2 66.96s67.19-29.98 67.19-66.96c-0.01-31.28-21.53-57.55-50.62-64.91zm-42.07 66.5c-11.46 0-20.74-9.25-20.74-20.67s9.29-20.68 20.74-20.68c11.46 0 20.75 9.26 20.75 20.68-0.01 11.42-9.29 20.67-20.75 20.67z"/><path class="st3" d="m258.35 6.94c-104.76 0-189.69 84.64-189.69 189.06 0 88.76 137.04 240.33 178.16 283.82 2.91 2.82 6.99 4.55 11.53 4.55 4.5 0 8.55-1.7 11.46-4.48 41.1-43.49 178.23-195.14 178.23-283.9 0.01-104.41-84.92-189.05-189.69-189.05zm0 328.12c-58.05 0-107.84-35.14-129.17-85.25-7.11-16.7-11.07-35.06-11.09-54.35v-0.22c0-77.21 62.79-139.82 140.27-139.82 77.47 0 140.29 62.6 140.29 139.82v0.24c-0.02 19.29-3.98 37.64-11.09 54.32-21.34 50.12-71.15 85.26-129.21 85.26z"/></svg>
    `);
    return `data:image/svg+xml;charset=UTF-8;base64,${encodedSVG}`;
};
