/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react';
import './Category.css';

interface Props {
    category: string;
}

interface State { }

export class Category extends React.Component<Props, State> {
    private className = "category"

    constructor(props: Props) {
        super(props);
        this.state = { }
    }

    public render() {
        const c = this.className;
        const { category } = this.props;

        return (
            <div className={c}>
                <b>{category.toUpperCase()}</b>
            </div>
        )
    }
}
