/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react';
import { UserInquiryState } from '../../models/state/GeneralUiState';
import { Modal } from 'reactstrap';
import { SavedQueryMap } from '../../models/Query';
import AskQuestion from './AskQuestion';
import './UserQuestionModal.css';

interface Props {
    dispatch: any;
    queries: SavedQueryMap;
    state: UserInquiryState;
}

export default class UserQuestionModal extends React.PureComponent<Props> {
    private className = 'user-question-modal';

    public render() {
        const c = this.className;
        const { dispatch, queries, state } = this.props;
        const { show } = this.props.state;

        return (
            <Modal isOpen={show} className={`${c} leaf-modal`} keyboard={true} size={'lg'}>
                <AskQuestion dispatch={dispatch} queries={queries} state={state} />
            </Modal>
        );
    }
}