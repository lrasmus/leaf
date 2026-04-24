/* Copyright (c) 2022, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react'
import { LatLngExpression, divIcon } from 'leaflet';
import { Marker } from 'react-leaflet';
import { CohortStateType } from '../../models/state/CohortState';

interface Props
{
    position: LatLngExpression,
    queryState: CohortStateType;
}

export default class EndpointMarker extends React.PureComponent<Props> {
    public render() {
        const classes = [ 'pulse-icon', (this.props.queryState === CohortStateType.LOADED ? 'pulse-icon-loaded' : '') ];
        const icon = divIcon({
            className: "pulse-icon-wrapper"
        });
        return (
            <Marker position={this.props.position} icon={icon}>
                <div className={classes.join(' ')} />
            </Marker>
        );
    }
}
